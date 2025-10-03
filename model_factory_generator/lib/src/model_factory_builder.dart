import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:model_factory/model_factory.dart';
import 'package:source_gen/source_gen.dart';

class ModelFactoryBuilder extends GeneratorForAnnotation<JsonSerializable> {
  final _jsonSerializableChecker =
      const TypeChecker.typeNamed(JsonSerializable, inPackage: 'model_factory');
  final _jsonKeyChecker =
      const TypeChecker.typeNamed(JsonKey, inPackage: 'model_factory');
  final _jsonIgnoreChecker =
      const TypeChecker.typeNamed(JsonIgnore, inPackage: 'model_factory');

  @override
  Future<String?> generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement2) {
      throw InvalidGenerationSourceError(
        '`@JsonSerializable` can only be used on classes.',
        element: element,
      );
    }

    final buffer = StringBuffer();

    final className = element.displayName;
    buffer.writeln(
      'class ${className}JsonAdapter extends JsonAdapter<$className?>{',
    );
    buffer.writeln(buildRegister(element));
    buffer.writeln(buildFromJson(element));
    buffer.writeln(buildToJson(element));
    buffer.writeln(buildMetaFields(element));
    buffer.writeln('}');

    buffer.writeln(buildCompatibility(element));

    buffer.writeln(buildExtension(element));
    buffer.writeln(buildClassFields(element));
    return buffer.toString();
  }

  String buildMetaFields(ClassElement2 element) {
    final buffer = StringBuffer();
    final className = element.displayName;
    buffer.writeln(
      '${className}Metadata get metadata => ${className}Metadata.instance;',
    );

    buffer.writeln('@override');
    buffer.writeln('List<JsonField> get allFields => metadata.allJsonFields;');
    return buffer.toString();
  }

  String buildRegister(ClassElement2 element) {
    final buffer = StringBuffer();
    final className = element.displayName;
    buffer.writeln(
      'static void register(){',
    );

    buffer.writeln(
      'GetIt.I.registerSingleton<JsonAdapter<$className?>>(${className}JsonAdapter());',
    );

    buffer.writeln(
      'GetIt.I.registerFactoryParam<$className, dynamic, dynamic>((json, _) => GetIt.I<JsonAdapter<$className?>>().fromJson(json)!);',
    );

    buffer.writeln('}');
    return buffer.toString();
  }

  String buildCompatibility(ClassElement2 element) {
    final buffer = StringBuffer();
    final className = element.displayName;
    buffer.writeln(
      '$className _\$${className}FromJson(dynamic json) => GetIt.I<JsonAdapter<$className?>>().fromJson(json)!;',
    );
    return buffer.toString();
  }

  Iterable<Element2> findGenericElements(DartType type) sync* {
    if (type is ParameterizedType) {
      if (type.typeArguments.isNotEmpty) {
        for (final i in type.typeArguments) {
          final el = i.element3;
          if (el is ClassElement2 &&
              _jsonSerializableChecker.hasAnnotationOfExact(el)) {
            yield el;

            yield* findGenericElements(el.thisType);
          }
        }
      }
    }
  }

  String buildFromJson(ClassElement2 classElement) {
    final buffer = StringBuffer();
    final className = classElement.displayName;

    buffer.write("@pragma('vm:entry-point')");
    buffer.writeln('@override');
    buffer.writeln(
      '$className? fromJson(dynamic json){',
    );

    buffer.writeln('if (json == null) return null;');
    buffer.writeln('try {');

    final List<String> added = [];
    for (final field in classElement.fields2) {
      final ce = field.type.element3;

      final els = findGenericElements(field.type);
      for (final el in els) {
        if (added.contains(el.displayName)) continue;
        added.add(el.displayName);
      }

      if (ce is ClassElement2) {
        if (added.contains(ce.displayName)) continue;
        added.add(ce.displayName);

        if (_jsonSerializableChecker.hasAnnotationOfExact(ce)) {}
      }
    }

    buffer.write(' return $className(');

    final supers = classElement.allSupertypes;
    for (final sup in supers) {
      buildFromJsonFields(sup.element3, buffer);
    }

    buildFromJsonFields(classElement, buffer);
    buffer.writeln(');');

    buffer.writeln('} on FieldParseException catch (e) {');
    buffer.writeln(
      "throw ModelParseException(innerException: e.innerException, key: e.key, className: '${classElement.name3}',);",
    );
    buffer.writeln('}}');
    return buffer.toString();
  }

  void buildFromJsonFields(
    InterfaceElement2 classElement,
    StringBuffer buffer,
  ) {
    if (!_jsonSerializableChecker.hasAnnotationOfExact(classElement)) {
      return;
    }

    final className = classElement.displayName;
    final constructorFields = <String>[];

    if (classElement.constructors2.isNotEmpty) {
      final constructor = classElement.constructors2.first;
      for (final parameter in constructor.formalParameters) {
        constructorFields.add(parameter.name3 ?? '');
      }
    }

    for (final field in classElement.fields2) {
      if (field.setter2 == null && !field.isFinal) continue;

      final fieldName = field.name3;
      if (!constructorFields.contains(fieldName)) continue;

      final isNullable =
          field.type.nullabilitySuffix == NullabilitySuffix.question;
      final type = field.type.getDisplayString(withNullability: false);

      final jsonIgnoreAnn = getFieldAnnotation(_jsonIgnoreChecker, field);

      if (jsonIgnoreAnn != null) {
        final ignoreFromJson =
            jsonIgnoreAnn.getField('ignoreFromJson')?.toBoolValue() ?? true;

        if (ignoreFromJson) continue;
      }

      final meta = '${className}Metadata.instance';

      Object? defaultValue;
      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, field);
      if (jsonKeyAnn != null) {
        final fromJson = jsonKeyAnn.getField('fromJson');
        if (fromJson != null) {
          final fn = fromJson.toFunctionValue();
          if (fn != null) {
            final functionName = fn.name;

            final deserializationInfo = '''DeserializationInfo(
              key: $meta.$fieldName,
              map: json,
              current: json[$meta.$fieldName],
            )''';

            buffer.writeln(
              '${field.name3} : $functionName($deserializationInfo,),',
            );
            continue;
          }
        }

        final converter = jsonKeyAnn.getField('withConverter')?.toTypeValue();
        if (converter != null) {
          buffer.writeln(
            '${field.name3} : tryConvertFromJson(${converter.element3!.name3}(), json[$meta.$fieldName]),',
          );
          continue;
        }

        final defaultValueField = jsonKeyAnn.getField('defaultValue');
        if (defaultValueField != null) {
          defaultValue = defaultValueField.toStringValue() ??
              defaultValueField.toBoolValue() ??
              defaultValueField.toDoubleValue() ??
              defaultValueField.toIntValue() ??
              defaultValueField.toListValue() ??
              defaultValueField.toMapValue() ??
              defaultValueField.toSymbolValue();
        }
      }

      final fieldTypeElement = field.type.element3;
      if (fieldTypeElement is ClassElement2 &&
          _jsonSerializableChecker.hasAnnotationOfExact(fieldTypeElement)) {
        final an =
            _jsonSerializableChecker.firstAnnotationOfExact(fieldTypeElement)!;

        final t = an.getField('withConverter')!;
        final ty = t.toTypeValue();
        if (ty != null) {
          buffer.writeln(
            '${field.name3} : ${ty.element3!.name3}().fromJson(json[$meta.$fieldName]),',
          );
          continue;
        }
      }

      var xtype = type;
      bool isList = false;
      if (field.type.isDartCoreList) {
        isList = true;
        xtype = type.substring(5, type.length - 1);
      }

      final List<String> params = [];

      if (isList) {
        params.add('isList: true');
      }

      if (!isNullable) {
        params.add('isNullable: false');
      } else {
        params.add('isNullable: true');
      }

      if (defaultValue != null) {
        final needQuotes =
            field.type.isDartCoreString || ['DateTime'].contains(xtype);

        if (needQuotes) {
          defaultValue = "'$defaultValue'";
        }

        params.add('defaultValue: $defaultValue');
      }

      String suffix = '';
      if (!isNullable) {
        suffix = '!';
      }

      final paramsString = params.join(', ');
      buffer.writeln(
        '${field.name3} : decode<$xtype>(json, $meta.$fieldName, $paramsString,)$suffix,',
      );
    }
  }

  String buildToJson(ClassElement2 classElement) {
    final className = classElement.displayName;
    final buffer = StringBuffer();

    buffer.write("@pragma('vm:entry-point')");
    buffer.writeln('@override');
    buffer.writeln(
      'dynamic toJson($className? instance){',
    );

    buffer.writeln('if (instance == null) return null;');

    final List<String> added = [];
    for (final field in classElement.fields2) {
      final ce = field.type.element3;

      final els = findGenericElements(field.type);
      for (final el in els) {
        if (added.contains(el.displayName)) continue;
        added.add(el.displayName);
      }

      if (ce is ClassElement2) {
        if (added.contains(ce.displayName)) continue;
        added.add(ce.displayName);

        if (_jsonSerializableChecker.hasAnnotationOfExact(ce)) {}
      }
    }

    buffer.writeln('return {');
    final supers = classElement.allSupertypes;
    for (final sup in supers) {
      buildToJsonFields(sup.element3, buffer);
    }

    buildToJsonFields(classElement, buffer);
    buffer.writeln('};');
    buffer.writeln('}');

    return buffer.toString();
  }

  DartObject? getFieldAnnotation(TypeChecker checker, FieldElement2 field) {
    if (checker.hasAnnotationOfExact(field)) {
      return checker.firstAnnotationOfExact(field);
    }

    final getter = field.getter2;
    if (getter != null && checker.hasAnnotationOfExact(getter)) {
      return checker.firstAnnotationOfExact(getter);
    }

    final setter = field.setter2;
    if (setter != null && checker.hasAnnotationOfExact(setter)) {
      return checker.firstAnnotationOfExact(setter);
    }

    return null;
  }

  void buildToJsonFields(InterfaceElement2 classElement, StringBuffer buffer) {
    if (!_jsonSerializableChecker.hasAnnotationOfExact(classElement)) {
      return;
    }

    final className = classElement.displayName;

    for (final field in classElement.fields2) {
      var fieldName = field.name3;
      if (['hashCode'].contains(fieldName)) continue;

      final isNullable =
          field.type.nullabilitySuffix == NullabilitySuffix.question;
      final type = field.type.getDisplayString(withNullability: false);

      final jsonIgnoreAnn = getFieldAnnotation(_jsonIgnoreChecker, field);
      if (jsonIgnoreAnn != null) {
        final ignoreToJson =
            jsonIgnoreAnn.getField('ignoreToJson')?.toBoolValue() ?? true;

        if (ignoreToJson) continue;
      }

      final meta = '${className}Metadata.instance';
      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, field);
      bool omitIfNull = true;

      if (jsonKeyAnn != null) {
        fieldName = jsonKeyAnn.getField('name')!.toStringValue()!;
        omitIfNull = jsonKeyAnn.getField('omitIfNull')?.toBoolValue() ?? true;
        final toJson = jsonKeyAnn.getField('toJson');
        if (toJson != null) {
          final fn = toJson.toFunctionValue2();
          if (fn != null) {
            final functionName = fn.name3;
            final String serializationInfo = '''SerializationInfo(
              key: $meta.${field.name3},
              data: instance.${field.name3},
            )''';

            buffer.writeln(
              '$meta.${field.name3} : $functionName($serializationInfo,),',
            );
            continue;
          }
        }

        final converter = jsonKeyAnn.getField('withConverter')?.toTypeValue();
        if (converter != null) {
          buffer.writeln(
            '$meta.${field.name3} : tryConvertToJson( ${converter.element3!.name3}(), instance.${field.name3}),',
          );
          continue;
        }
      }

      final fieldTypeElement = field.type.element3;
      if (fieldTypeElement is ClassElement2 &&
          _jsonSerializableChecker.hasAnnotationOfExact(fieldTypeElement)) {
        final an =
            _jsonSerializableChecker.firstAnnotationOfExact(fieldTypeElement)!;

        final t = an.getField('withConverter')!;
        final ty = t.toTypeValue();
        if (ty != null) {
          if (omitIfNull && isNullable) {
            buffer.writeln(
              'if (instance.${field.name3} != null) ',
            );
          }
          buffer.writeln(
            '$meta.${field.name3} : ${ty.element3!.name3}().toJson(instance.${field.name3}),',
          );
          continue;
        }
      }

      var xtype = type;
      if (field.type.isDartCoreList) {
        xtype = type.substring(5, type.length - 1);
      }

      if (omitIfNull && isNullable) {
        buffer.writeln(
          'if (instance.${field.name3} != null) ',
        );
      }

      buffer.writeln(
        '$meta.${field.name3} : encode<$xtype>(instance.${field.name3}, $meta.${field.name3})${isNullable ? '' : '!'},',
      );
    }
  }

  String buildExtension(ClassElement2 cl) {
    final className = cl.displayName;
    final buffer = StringBuffer();

    buffer.writeln('extension ${className}JsonExtension on $className {');
    buffer.write("@pragma('vm:entry-point')");
    buffer.writeln(
      'dynamic toJson() => GetIt.I<JsonAdapter<$className?>>().toJson(this);',
    );
    buffer.writeln(buildSetValue(cl));
    buffer.writeln(buildGetValue(cl));
    buffer.writeln(buildCopyWith(cl));
    buffer.writeln(buildApply(cl));
    buffer.writeln(buildClone(cl));
    buffer.writeln(
      '${className}Metadata get metadata => ${className}Metadata.instance;',
    );
    buffer.writeln('}');

    return buffer.toString();
  }

  String buildSetValue(ClassElement2 cl) {
    final fields = getFields(cl);
    final buffer = StringBuffer();
    buffer.writeln('void setValue(String field, dynamic value){');
    buffer.writeln('switch (field) {');
    for (final f in fields) {
      var name = f.name3;
      if (['hashCode'].contains(name)) continue;

      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);
      if (jsonKeyAnn != null) {
        name = jsonKeyAnn.getField('name')!.toStringValue()!;
      }

      if (f.setter2 == null || f.isFinal) continue;
      buffer.writeln('case \'$name\': ${f.name3} = value; break;');
    }
    buffer.write('}');
    buffer.write('}');
    return buffer.toString();
  }

  String buildGetValue(ClassElement2 cl) {
    final fields = getFields(cl);
    final buffer = StringBuffer();
    buffer.writeln('dynamic getValue(String field){');
    buffer.writeln('switch (field) {');
    for (final f in fields) {
      var name = f.name3;
      if (['hashCode'].contains(name)) continue;

      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);
      if (jsonKeyAnn != null) {
        name = jsonKeyAnn.getField('name')!.toStringValue()!;
      }

      if (f.getter2 == null) continue;

      buffer.writeln('case \'$name\': return ${f.name3};');
    }
    buffer.write('}');

    buffer.write('return null;');
    buffer.write('}');
    return buffer.toString();
  }

  String buildClassFields(ClassElement2 cl) {
    final className = cl.displayName;
    final buffer = StringBuffer();

    buffer.writeln('class ${className}Metadata {');
    buffer.writeln(
      'static final ${className}Metadata instance = ${className}Metadata._();',
    );

    buffer.writeln('${className}Metadata._();');
    buffer.writeln(buildFields(cl));
    buffer.writeln(buildMetaFieldList(cl));
    buffer.writeln(buildMetaAllFieldList(cl));
    buffer.writeln(buildMetaAllAliasFieldList(cl));
    buffer.writeln(buildMetaAllJSONFieldList(cl));
    buffer.writeln(getValueByField(cl));
    buffer.writeln('}');

    return buffer.toString();
  }

  List<FieldElement2> getFields(ClassElement2 cl) {
    return [...getSuperFields(cl), ...getLocalFields(cl)];
  }

  List<FieldElement2> getLocalFields(ClassElement2 cl) {
    final result = <FieldElement2>[];
    for (final f in cl.fields2) {
      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);
      if (jsonKeyAnn != null) {
        result.add(f);
      }
    }

    return result;
  }

  List<FieldElement2> getSuperFields(ClassElement2 cl) {
    final result = <FieldElement2>[];
    final s = cl.supertype;
    if (s != null && s.element3 is ClassElement2) {
      return [
        ...getSuperFields(s.element3 as ClassElement2),
        ...getLocalFields(s.element3 as ClassElement2),
      ];
    }

    return result;
  }

  String getValueByField(ClassElement2 cl) {
    final className = cl.displayName;
    final buffer = StringBuffer();
    buffer.write('dynamic valueOf($className instance, String fieldName) { ');
    buffer.writeln('switch (fieldName) {');
    for (final f in getFields(cl)) {
      var name = f.name3;
      if (['hashCode'].contains(name)) continue;

      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);
      if (jsonKeyAnn != null) {
        name = jsonKeyAnn.getField('name')!.toStringValue()!;
      }

      buffer.writeln('case \'$name\': return instance.${f.name3};');
    }
    buffer.writeln('default: return null;');
    buffer.write('}}');
    return buffer.toString();
  }

  String buildMetaAllAliasFieldList(ClassElement2 cl) {
    final buffer = StringBuffer();
    buffer.write('Map<String, String> get aliases => ');
    buffer.write('{');
    for (final f in getFields(cl)) {
      var name = f.name3;
      String? alias;

      if (['hashCode'].contains(name)) continue;

      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);
      if (jsonKeyAnn != null) {
        name = jsonKeyAnn.getField('name')!.toStringValue()!;
        alias = jsonKeyAnn.getField('alias')?.toStringValue();
        if (alias == null) {
          continue;
        }
      }

      buffer.write('\'$name\' : \'$alias\',');
    }
    buffer.write('};');
    return buffer.toString();
  }

  String buildMetaAllJSONFieldList(ClassElement2 cl) {
    final className = cl.displayName;
    final buffer = StringBuffer();
    buffer.write('List<JsonField> get allJsonFields => ');
    buffer.write('[');

    final localFields = getLocalFields(cl);
    final superFields = getSuperFields(cl);

    for (final f in [...localFields, ...superFields]) {
      var name = f.name3;
      String? alias;
      if (['hashCode'].contains(name)) continue;

      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);

      if (jsonKeyAnn != null) {
        name = jsonKeyAnn.getField('name')!.toStringValue()!;
        alias = jsonKeyAnn.getField('alias')!.toStringValue();
      }

      buffer.write('JsonField<$className>(');
      buffer.write('name: \'${f.name3}\',');
      buffer.write('field: \'$name\',');
      if (alias != null) {
        buffer.write('alias: \'$alias\',');
      } else {
        buffer.write('alias: null,');
      }

      buffer.write(
        'fieldType: ${f.type.getDisplayString(withNullability: false)},',
      );

      final isSuper = superFields.contains(f);
      buffer.write('fromSuper: $isSuper,');
      buffer.write('handler: (instance) => instance.${f.name3},');
      buffer.writeln('),');
    }

    buffer.write('];');
    return buffer.toString();
  }

  String buildMetaAllFieldList(ClassElement2 cl) {
    final buffer = StringBuffer();
    buffer.write('List<String> get allFields => ');
    buffer.write('[');
    for (final f in getFields(cl)) {
      var name = f.name3;
      if (['hashCode'].contains(name)) continue;

      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);
      if (jsonKeyAnn != null) {
        name = jsonKeyAnn.getField('name')!.toStringValue()!;
      }

      buffer.write(' \'$name\',');
    }
    buffer.write('];');
    return buffer.toString();
  }

  String buildMetaFieldList(ClassElement2 cl) {
    final buffer = StringBuffer();
    buffer.write('List<String> get fields => ');
    buffer.write('[');
    for (final f in cl.fields2) {
      var name = f.name3;
      if (['hashCode'].contains(name)) continue;

      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);
      if (jsonKeyAnn != null) {
        name = jsonKeyAnn.getField('name')!.toStringValue()!;
      }

      buffer.write(' \'$name\',');
    }
    buffer.write('];');
    return buffer.toString();
  }

  String buildFields(ClassElement2 cl) {
    final buffer = StringBuffer();

    for (final f in cl.fields2) {
      var name = f.name3;
      if (['hashCode'].contains(name)) continue;

      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);
      if (jsonKeyAnn != null) {
        name = jsonKeyAnn.getField('name')!.toStringValue()!;
      }

      buffer.writeln('final String ${f.name3} = \'$name\';');
    }

    return buffer.toString();
  }

  String buildApply(ClassElement2 cl) {
    final className = cl.displayName;
    final buffer = StringBuffer();

    buffer.writeln('void apply($className other){');
    for (final f in cl.fields2) {
      if (f.setter2 == null || f.isFinal) continue;
      final name = f.name3;
      buffer.writeln('$name = other.$name;');
    }
    buffer.writeln('}');

    return buffer.toString();
  }

  String buildCopyWith(ClassElement2 cl) {
    final className = cl.displayName;

    if (cl.constructors2.isEmpty) {
      return '';
    }

    final constructor = cl.constructors2.first;
    if (constructor.formalParameters.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    buffer.write('$className copyWith({');
    for (final f in constructor.formalParameters) {
      final name = f.name3;
      String type = f.type.getDisplayString();
      final isNullable = type.contains('?');
      if (isNullable) {
        type = type.replaceAll('?', '');
      }

      var t = type;
      if (f.type is! DynamicType) {
        t = '$t?';
      }

      buffer.writeln('$t $name,');
    }

    final fields = cl.fields2
        .where(
          (a) => !constructor.formalParameters.any((b) => b.name3 == a.name3),
        )
        .toList();

    for (final f in fields) {
      if (f.setter2 == null || f.isFinal) continue;

      final name = f.name3;
      String type = f.type.getDisplayString();
      final isNullable = type.contains('?');
      if (isNullable) {
        type = type.replaceAll('?', '');
      }

      buffer.writeln('$type? $name,');
    }

    buffer.writeln('}) => $className(');
    for (final f in constructor.formalParameters) {
      final name = f.name3;
      buffer.writeln('$name: $name ?? this.$name,');
    }

    buffer.write(')');
    for (final f in fields) {
      if (f.setter2 == null || f.isFinal) continue;

      final name = f.name3;
      buffer.writeln('..$name = $name ?? this.$name');
    }

    buffer.writeln(';');

    return buffer.toString();
  }

  String buildClone(ClassElement2 cl) {
    final className = cl.displayName;
    final buffer = StringBuffer();

    buffer.writeln('$className clone() => ');
    buffer.writeln('GetIt.I<JsonAdapter<$className?>>().fromJson(toJson()!)!;');

    return buffer.toString();
  }
}
