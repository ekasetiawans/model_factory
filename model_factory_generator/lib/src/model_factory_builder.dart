import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:model_factory/model_factory.dart';
import 'package:source_gen/source_gen.dart';

class ModelFactoryBuilder extends GeneratorForAnnotation<JsonSerializable> {
  final _jsonSerializableChecker =
      const TypeChecker.fromRuntime(JsonSerializable);
  final _jsonKeyChecker = const TypeChecker.fromRuntime(JsonKey);
  final _jsonIgnoreChecker = const TypeChecker.fromRuntime(JsonIgnore);

  @override
  Future<String?> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (!element.library!.isNonNullableByDefault) {
      throw InvalidGenerationSourceError(
        'Generator cannot target libraries that have not been migrated to '
        'null-safety.',
        element: element,
      );
    }

    if (element is! ClassElement) {
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

  String buildMetaFields(ClassElement element) {
    final buffer = StringBuffer();
    final className = element.displayName;
    buffer.writeln(
      '${className}Metadata get metadata => ${className}Metadata.instance;',
    );
    buffer.writeln('List<JsonField> get allFields => metadata.allJsonFields;');
    return buffer.toString();
  }

  String buildRegister(ClassElement element) {
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

  String buildCompatibility(ClassElement element) {
    final buffer = StringBuffer();
    final className = element.displayName;
    buffer.writeln(
      '_\$${className}FromJson(dynamic json) => GetIt.I<JsonAdapter<$className?>>().fromJson(json)!;',
    );
    return buffer.toString();
  }

  Iterable<Element> findGenericElements(DartType type) sync* {
    if (type is ParameterizedType) {
      if (type.typeArguments.isNotEmpty) {
        for (final i in type.typeArguments) {
          final el = i.element;
          if (el is ClassElement &&
              _jsonSerializableChecker.hasAnnotationOfExact(el)) {
            yield el;

            yield* findGenericElements(el.thisType);
          }
        }
      }
    }
  }

  String buildFromJson(ClassElement classElement) {
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
    for (final field in classElement.fields) {
      final ce = field.type.element;

      final els = findGenericElements(field.type);
      for (final el in els) {
        if (added.contains(el.displayName)) continue;
        added.add(el.displayName);
      }

      if (ce is ClassElement) {
        if (added.contains(ce.displayName)) continue;
        added.add(ce.displayName);

        if (_jsonSerializableChecker.hasAnnotationOfExact(ce)) {}
      }
    }

    buffer.write(' return $className(');

    final supers = classElement.allSupertypes;
    for (final sup in supers) {
      buildFromJsonFields(sup.element, buffer);
    }

    buildFromJsonFields(classElement, buffer);
    buffer.writeln(');');

    buffer.writeln('} on FieldParseException catch (e) {');
    buffer.writeln(
      "throw ModelParseException(innerException: e.innerException, key: e.key, className: '${classElement.name}',);",
    );
    buffer.writeln('}}');
    return buffer.toString();
  }

  void buildFromJsonFields(InterfaceElement classElement, StringBuffer buffer) {
    if (!_jsonSerializableChecker.hasAnnotationOfExact(classElement)) {
      return;
    }

    final className = classElement.displayName;
    final constructorFields = <String>[];

    if (classElement.constructors.isNotEmpty) {
      final constructor = classElement.constructors.first;
      for (final parameter in constructor.parameters) {
        constructorFields.add(parameter.declaration.name);
      }
    }

    for (final field in classElement.fields) {
      if (field.setter == null && !field.isFinal) continue;

      final fieldName = field.name;
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
              '${field.name} : $functionName($deserializationInfo,),',
            );
            continue;
          }
        }

        final converter = jsonKeyAnn.getField('withConverter')?.toTypeValue();
        if (converter != null) {
          buffer.writeln(
            '${field.name} : tryConvertFromJson(${converter.element!.name}(), json[$meta.$fieldName]),',
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

      final fieldTypeElement = field.type.element;
      if (fieldTypeElement is ClassElement &&
          _jsonSerializableChecker.hasAnnotationOfExact(fieldTypeElement)) {
        final an =
            _jsonSerializableChecker.firstAnnotationOfExact(fieldTypeElement)!;

        final t = an.getField('withConverter')!;
        final ty = t.toTypeValue();
        if (ty != null) {
          buffer.writeln(
            '${field.name} : ${ty.element!.name}().fromJson(json[$meta.$fieldName]),',
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
        '${field.name} : decode<$xtype>(json, $meta.$fieldName, $paramsString,)$suffix,',
      );
    }
  }

  String buildToJson(ClassElement classElement) {
    final className = classElement.displayName;
    final buffer = StringBuffer();

    buffer.write("@pragma('vm:entry-point')");
    buffer.writeln('@override');
    buffer.writeln(
      'dynamic toJson($className? instance){',
    );

    buffer.writeln('if (instance == null) return null;');

    final List<String> added = [];
    for (final field in classElement.fields) {
      final ce = field.type.element;

      final els = findGenericElements(field.type);
      for (final el in els) {
        if (added.contains(el.displayName)) continue;
        added.add(el.displayName);
      }

      if (ce is ClassElement) {
        if (added.contains(ce.displayName)) continue;
        added.add(ce.displayName);

        if (_jsonSerializableChecker.hasAnnotationOfExact(ce)) {}
      }
    }

    buffer.writeln('return {');
    final supers = classElement.allSupertypes;
    for (final sup in supers) {
      buildToJsonFields(sup.element, buffer);
    }

    buildToJsonFields(classElement, buffer);
    buffer.writeln('};');
    buffer.writeln('}');

    return buffer.toString();
  }

  DartObject? getFieldAnnotation(TypeChecker checker, FieldElement field) {
    if (checker.hasAnnotationOfExact(field)) {
      return checker.firstAnnotationOfExact(field);
    }

    final getter = field.getter;
    if (getter != null && checker.hasAnnotationOfExact(getter)) {
      return checker.firstAnnotationOfExact(getter);
    }

    final setter = field.setter;
    if (setter != null && checker.hasAnnotationOfExact(setter)) {
      return checker.firstAnnotationOfExact(setter);
    }

    return null;
  }

  void buildToJsonFields(InterfaceElement classElement, StringBuffer buffer) {
    if (!_jsonSerializableChecker.hasAnnotationOfExact(classElement)) {
      return;
    }

    final className = classElement.displayName;

    for (final field in classElement.fields) {
      var fieldName = field.name;
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
          final fn = toJson.toFunctionValue();
          if (fn != null) {
            final functionName = fn.name;
            final String serializationInfo = '''SerializationInfo(
              key: $meta.${field.name},
              data: instance.${field.name},
            )''';

            buffer.writeln(
              '$meta.${field.name} : $functionName($serializationInfo,),',
            );
            continue;
          }
        }

        final converter = jsonKeyAnn.getField('withConverter')?.toTypeValue();
        if (converter != null) {
          buffer.writeln(
            '$meta.${field.name} : tryConvertToJson( ${converter.element!.name}(), instance.${field.name}),',
          );
          continue;
        }
      }

      final fieldTypeElement = field.type.element;
      if (fieldTypeElement is ClassElement &&
          _jsonSerializableChecker.hasAnnotationOfExact(fieldTypeElement)) {
        final an =
            _jsonSerializableChecker.firstAnnotationOfExact(fieldTypeElement)!;

        final t = an.getField('withConverter')!;
        final ty = t.toTypeValue();
        if (ty != null) {
          if (omitIfNull && isNullable) {
            buffer.writeln(
              'if (instance.${field.name} != null) ',
            );
          }
          buffer.writeln(
            '$meta.${field.name} : ${ty.element!.name}().toJson(instance.${field.name}),',
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
          'if (instance.${field.name} != null) ',
        );
      }

      buffer.writeln(
        '$meta.${field.name} : encode<$xtype>(instance.${field.name}, $meta.${field.name})${isNullable ? '' : '!'},',
      );
    }
  }

  String buildExtension(ClassElement cl) {
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

  String buildSetValue(ClassElement cl) {
    final fields = getFields(cl);
    final buffer = StringBuffer();
    buffer.writeln('void setValue(String field, dynamic value){');
    buffer.writeln('switch (field) {');
    for (final f in fields) {
      var name = f.name;
      if (['hashCode'].contains(name)) continue;

      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);
      if (jsonKeyAnn != null) {
        name = jsonKeyAnn.getField('name')!.toStringValue()!;
      }

      if (f.setter == null || f.isFinal) continue;
      buffer.writeln('case \'$name\': ${f.name} = value; break;');
    }
    buffer.write('}');
    buffer.write('}');
    return buffer.toString();
  }

  String buildGetValue(ClassElement cl) {
    final fields = getFields(cl);
    final buffer = StringBuffer();
    buffer.writeln('dynamic getValue(String field){');
    buffer.writeln('switch (field) {');
    for (final f in fields) {
      var name = f.name;
      if (['hashCode'].contains(name)) continue;

      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);
      if (jsonKeyAnn != null) {
        name = jsonKeyAnn.getField('name')!.toStringValue()!;
      }

      if (f.getter == null) continue;

      buffer.writeln('case \'$name\': return ${f.name};');
    }
    buffer.write('}');

    buffer.write('return null;');
    buffer.write('}');
    return buffer.toString();
  }

  String buildClassFields(ClassElement cl) {
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

  List<FieldElement> getFields(ClassElement cl) {
    return [...getSuperFields(cl), ...getLocalFields(cl)];
  }

  List<FieldElement> getLocalFields(ClassElement cl) {
    final result = <FieldElement>[];
    for (final f in cl.fields) {
      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);
      if (jsonKeyAnn != null) {
        result.add(f);
      }
    }

    return result;
  }

  List<FieldElement> getSuperFields(ClassElement cl) {
    final result = <FieldElement>[];
    final s = cl.supertype;
    if (s != null && s.element is ClassElement) {
      return [
        ...getSuperFields(s.element as ClassElement),
        ...getLocalFields(s.element as ClassElement),
      ];
    }

    return result;
  }

  String getValueByField(ClassElement cl) {
    final className = cl.displayName;
    final buffer = StringBuffer();
    buffer.write('dynamic valueOf($className instance, String fieldName) { ');
    buffer.writeln('switch (fieldName) {');
    for (final f in getFields(cl)) {
      var name = f.name;
      if (['hashCode'].contains(name)) continue;

      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);
      if (jsonKeyAnn != null) {
        name = jsonKeyAnn.getField('name')!.toStringValue()!;
      }

      buffer.writeln('case \'$name\': return instance.${f.name};');
    }
    buffer.writeln('default: return null;');
    buffer.write('}}');
    return buffer.toString();
  }

  String buildMetaAllAliasFieldList(ClassElement cl) {
    final buffer = StringBuffer();
    buffer.write('Map<String, String> get aliases => ');
    buffer.write('{');
    for (final f in getFields(cl)) {
      var name = f.name;
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

  String buildMetaAllJSONFieldList(ClassElement cl) {
    final className = cl.displayName;
    final buffer = StringBuffer();
    buffer.write('List<JsonField> get allJsonFields => ');
    buffer.write('[');

    final localFields = getLocalFields(cl);
    final superFields = getSuperFields(cl);

    for (final f in [...localFields, ...superFields]) {
      var name = f.name;
      String? alias;
      if (['hashCode'].contains(name)) continue;

      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);

      if (jsonKeyAnn != null) {
        name = jsonKeyAnn.getField('name')!.toStringValue()!;
        alias = jsonKeyAnn.getField('alias')!.toStringValue();
      }

      buffer.write('JsonField<$className>(');
      buffer.write('name: \'${f.name}\',');
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
      buffer.write('handler: (instance) => instance.${f.name},');
      buffer.writeln('),');
    }

    buffer.write('];');
    return buffer.toString();
  }

  String buildMetaAllFieldList(ClassElement cl) {
    final buffer = StringBuffer();
    buffer.write('List<String> get allFields => ');
    buffer.write('[');
    for (final f in getFields(cl)) {
      var name = f.name;
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

  String buildMetaFieldList(ClassElement cl) {
    final buffer = StringBuffer();
    buffer.write('List<String> get fields => ');
    buffer.write('[');
    for (final f in cl.fields) {
      var name = f.name;
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

  String buildFields(ClassElement cl) {
    final buffer = StringBuffer();

    for (final f in cl.fields) {
      var name = f.name;
      if (['hashCode'].contains(name)) continue;

      final jsonKeyAnn = getFieldAnnotation(_jsonKeyChecker, f);
      if (jsonKeyAnn != null) {
        name = jsonKeyAnn.getField('name')!.toStringValue()!;
      }

      buffer.writeln('final String ${f.name} = \'$name\';');
    }

    return buffer.toString();
  }

  String buildApply(ClassElement cl) {
    final className = cl.displayName;
    final buffer = StringBuffer();

    buffer.writeln('void apply($className other){');
    for (final f in cl.fields) {
      if (f.setter == null || f.isFinal) continue;
      final name = f.name;
      buffer.writeln('$name = other.$name;');
    }
    buffer.writeln('}');

    return buffer.toString();
  }

  String buildCopyWith(ClassElement cl) {
    final className = cl.displayName;

    if (cl.constructors.isEmpty) {
      return '';
    }

    final constructor = cl.constructors.first;
    if (constructor.parameters.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    buffer.write('$className copyWith({');
    for (final f in constructor.parameters) {
      final name = f.name;
      String type = f.type.getDisplayString(withNullability: true);
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

    final fields = cl.fields
        .where((a) => !constructor.parameters.any((b) => b.name == a.name))
        .toList();

    for (final f in fields) {
      if (f.setter == null || f.isFinal) continue;

      final name = f.name;
      String type = f.type.getDisplayString(withNullability: true);
      final isNullable = type.contains('?');
      if (isNullable) {
        type = type.replaceAll('?', '');
      }

      buffer.writeln('$type? $name,');
    }

    buffer.writeln('}) => $className(');
    for (final f in constructor.parameters) {
      final name = f.name;
      buffer.writeln('$name: $name ?? this.$name,');
    }

    buffer.write(')');
    for (final f in fields) {
      if (f.setter == null || f.isFinal) continue;

      final name = f.name;
      buffer.writeln('..$name = $name ?? this.$name');
    }

    buffer.writeln(';');

    return buffer.toString();
  }

  String buildClone(ClassElement cl) {
    final className = cl.displayName;
    final buffer = StringBuffer();

    buffer.writeln('$className clone() => ');
    buffer.writeln('GetIt.I<JsonAdapter<$className?>>().fromJson(toJson()!)!;');

    return buffer.toString();
  }
}
