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
    buffer.writeln(buildFromJson(element));
    buffer.writeln(buildToJson(element));
    buffer.writeln(buildExtension(element));
    buffer.writeln(buildClassFields(element));
    return buffer.toString();
  }

  Iterable<Element> findGenericElements(DartType type) sync* {
    if (type is ParameterizedType) {
      if (type.typeArguments.isNotEmpty) {
        for (final i in type.typeArguments) {
          final el = i.element2;
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
    buffer.writeln(
      'typedef ${className}JsonDeserializer = $className Function(Map<String, dynamic> json);',
    );

    buffer.writeln(
      'final ${className}JsonDeserializer default${className}Deserializer = (Map<String, dynamic> json,) {',
    );

    buffer.writeln('try {');

    final List<String> added = [];
    for (final field in classElement.fields) {
      final ce = field.type.element2;

      final els = findGenericElements(field.type);
      for (final el in els) {
        if (added.contains(el.displayName)) continue;
        added.add(el.displayName);
        //buffer.writeln('${el.displayName}Metadata.registerFactory();');
      }

      if (ce is ClassElement) {
        if (added.contains(ce.displayName)) continue;
        added.add(ce.displayName);

        if (_jsonSerializableChecker.hasAnnotationOfExact(ce)) {
          //final className = ce.displayName;
          //buffer.writeln('${className}Metadata.registerFactory();');
        }
      }
    }

    buffer.write(' return $className(');

    final supers = classElement.allSupertypes;
    for (final sup in supers) {
      buildFromJsonFields(sup.element2, buffer);
    }

    buildFromJsonFields(classElement, buffer);
    buffer.writeln(');');

    buffer.writeln('} on FieldParseException catch (e) {');
    buffer.writeln(
      "throw ModelParseException(innerException: e.innerException, key: e.key, className: '${classElement.name}',);",
    );
    buffer.writeln('}');
    buffer.writeln('};');

    buffer.writeln(
      '$className _\$${className}FromJson(Map<String, dynamic> json) => default${className}Deserializer(json);',
    );

    buffer.writeln();
    buffer.writeln();

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
      final type = field.type.getDisplayString(withNullability: isNullable);

      if (_jsonIgnoreChecker.hasAnnotationOfExact(field)) {
        final ann = _jsonIgnoreChecker.firstAnnotationOfExact(field)!;
        final ignoreFromJson =
            ann.getField('ignoreFromJson')?.toBoolValue() ?? true;

        if (ignoreFromJson) continue;
      }

      final meta = '${className}Metadata.instance';

      if (_jsonKeyChecker.hasAnnotationOfExact(field)) {
        final jsonKey = _jsonKeyChecker.firstAnnotationOfExact(field)!;

        final fromJson = jsonKey.getField('fromJson');
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

        final converter = jsonKey.getField('withConverter')?.toTypeValue();
        if (converter != null) {
          buffer.writeln(
            '${field.name} : ${converter.element2!.name}().fromJson(json[$meta.$fieldName]),',
          );
          continue;
        }
      }

      final fieldTypeElement = field.type.element2;
      if (fieldTypeElement is ClassElement &&
          _jsonSerializableChecker.hasAnnotationOfExact(fieldTypeElement)) {
        final an =
            _jsonSerializableChecker.firstAnnotationOfExact(fieldTypeElement)!;

        final t = an.getField('withConverter')!;
        final ty = t.toTypeValue();
        if (ty != null) {
          buffer.writeln(
            '${field.name} : ${ty.element2!.name}().fromJson(json[$meta.$fieldName]),',
          );
          continue;
        }
      }

      buffer.writeln('${field.name} : json.value<$type>($meta.$fieldName,),');
    }
  }

  String buildToJson(ClassElement classElement) {
    final className = classElement.displayName;
    final buffer = StringBuffer();

    buffer.writeln(
      'typedef ${className}JsonSerializer = Map<String, dynamic> Function($className instance);',
    );

    buffer.writeln(
      'final ${className}JsonSerializer default${className}Serializer = ($className instance){',
    );

    final List<String> added = [];
    for (final field in classElement.fields) {
      final ce = field.type.element2;

      final els = findGenericElements(field.type);
      for (final el in els) {
        if (added.contains(el.displayName)) continue;
        added.add(el.displayName);
        //buffer.writeln('${el.displayName}Metadata.registerFactory();');
      }

      if (ce is ClassElement) {
        if (added.contains(ce.displayName)) continue;
        added.add(ce.displayName);

        if (_jsonSerializableChecker.hasAnnotationOfExact(ce)) {
          //final className = ce.displayName;
          //buffer.writeln('${className}Metadata.registerFactory();');
        }
      }
    }

    buffer.writeln('return {');
    final supers = classElement.allSupertypes;
    for (final sup in supers) {
      buildToJsonFields(sup.element2, buffer);
    }

    buildToJsonFields(classElement, buffer);
    buffer.writeln('};\n};\n');
    buffer.writeln(
      'Map<String, dynamic> _\$${className}ToJson($className instance)  => default${className}Serializer(instance);',
    );
    return buffer.toString();
  }

  void buildToJsonFields(InterfaceElement classElement, StringBuffer buffer) {
    if (!_jsonSerializableChecker.hasAnnotationOfExact(classElement)) {
      return;
    }

    final className = classElement.displayName;
    for (final field in classElement.fields) {
      if (field.setter == null &&
          !field.isFinal &&
          !_jsonKeyChecker.hasAnnotationOf(field)) {
        continue;
      }

      var fieldName = field.name;
      if (['hashCode'].contains(fieldName)) continue;

      final isNullable =
          field.type.nullabilitySuffix == NullabilitySuffix.question ||
              field.type.isDynamic;

      if (_jsonIgnoreChecker.hasAnnotationOf(field)) {
        final ann = _jsonIgnoreChecker.firstAnnotationOfExact(field)!;
        final ignoreToJson =
            ann.getField('ignoreToJson')?.toBoolValue() ?? true;

        if (ignoreToJson) continue;
      }

      final meta = '${className}Metadata.instance';

      if (_jsonKeyChecker.hasAnnotationOf(field)) {
        final ann = _jsonKeyChecker.firstAnnotationOfExact(field)!;
        fieldName = ann.getField('name')!.toStringValue()!;

        final toJson = ann.getField('toJson');
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

        final converter = ann.getField('withConverter')?.toTypeValue();
        if (converter != null) {
          buffer.writeln(
            '$meta.${field.name} : ${converter.element2!.name}().toJson(instance.${field.name}),',
          );
          continue;
        }
      }

      final fieldTypeElement = field.type.element2;
      if (fieldTypeElement is ClassElement &&
          _jsonSerializableChecker.hasAnnotationOfExact(fieldTypeElement)) {
        final an =
            _jsonSerializableChecker.firstAnnotationOfExact(fieldTypeElement)!;

        final t = an.getField('withConverter')!;
        final ty = t.toTypeValue();
        if (ty != null) {
          buffer.writeln(
            '$meta.${field.name} : ${ty.element2!.name}().toJson(instance.${field.name}),',
          );
          continue;
        }
      }

      var suffix = '';
      if (!field.type.isDartCoreBool &&
          !field.type.isDartCoreDouble &&
          !field.type.isDartCoreInt &&
          !field.type.isDartCoreIterable &&
          !field.type.isDartCoreList &&
          !field.type.isDartCoreMap &&
          !field.type.isDartCoreNum &&
          !field.type.isDartCoreSet &&
          !field.type.isDartCoreString) {
        suffix = '${isNullable ? '?' : ''}.toJson()';
      }

      if (field.type.getDisplayString(withNullability: false) == 'DateTime') {
        suffix = '${isNullable ? '?' : ''}.toUtc().toIso8601String()';
      }

      final coreList = <String>[
        'List<String>',
        'List<int>',
        'List<double>',
        'List<num>',
        'List<bool>',
      ];

      if (field.type.isDartCoreList &&
          !coreList
              .contains(field.type.getDisplayString(withNullability: false))) {
        suffix = '${isNullable ? '?' : ''}.map((e) => e.toJson()).toList()';
      }

      buffer.writeln('$meta.${field.name} : instance.${field.name}$suffix,');
    }
  }

  String buildExtension(ClassElement cl) {
    final className = cl.displayName;
    final buffer = StringBuffer();

    buffer.writeln('extension ${className}JsonExtension on $className {');
    buffer.writeln(
      'Map<String, dynamic> toJson() => _\$${className}ToJson(this);',
    );
    buffer.writeln(buildCopyWith(cl));
    buffer.writeln(buildApply(cl));
    buffer.writeln(buildClone(cl));
    buffer.writeln(
      '${className}Metadata get metadata => ${className}Metadata.instance;',
    );
    buffer.writeln('}');

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
      if (_jsonKeyChecker.hasAnnotationOfExact(f)) {
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

      if (_jsonKeyChecker.hasAnnotationOfExact(f)) {
        final ann = _jsonKeyChecker.firstAnnotationOfExact(f)!;
        name = ann.getField('name')!.toStringValue()!;
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

      if (_jsonKeyChecker.hasAnnotationOfExact(f)) {
        final ann = _jsonKeyChecker.firstAnnotationOfExact(f)!;
        name = ann.getField('name')!.toStringValue()!;
        alias = ann.getField('alias')?.toStringValue();
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

      if (_jsonKeyChecker.hasAnnotationOfExact(f)) {
        final ann = _jsonKeyChecker.firstAnnotationOfExact(f)!;
        name = ann.getField('name')!.toStringValue()!;
        alias = ann.getField('alias')!.toStringValue();
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
      buffer.write('valueOf: (instance) => instance.${f.name},');
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

      if (_jsonKeyChecker.hasAnnotationOfExact(f)) {
        final ann = _jsonKeyChecker.firstAnnotationOfExact(f)!;
        name = ann.getField('name')!.toStringValue()!;
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

      if (_jsonKeyChecker.hasAnnotationOfExact(f)) {
        final ann = _jsonKeyChecker.firstAnnotationOfExact(f)!;
        name = ann.getField('name')!.toStringValue()!;
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

      if (_jsonKeyChecker.hasAnnotationOfExact(f)) {
        final ann = _jsonKeyChecker.firstAnnotationOfExact(f)!;
        name = ann.getField('name')!.toStringValue()!;
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
    final buffer = StringBuffer();

    buffer.write('$className copyWith({');
    for (final f in constructor.parameters) {
      final name = f.name;
      String type = f.type.getDisplayString(withNullability: true);
      final isNullable = type.contains('?');
      if (isNullable) {
        type = type.replaceAll('?', '');
      }

      buffer.writeln('$type? $name,');
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
    buffer.writeln('_\$${className}FromJson(toJson());');

    return buffer.toString();
  }
}
