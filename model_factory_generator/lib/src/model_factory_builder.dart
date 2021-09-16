import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:model_factory/model_factory.dart';
import 'package:source_gen/source_gen.dart';

class ModelFactoryBuilder extends GeneratorForAnnotation<JsonSerializable> {
  final _jsonKeyChecker = const TypeChecker.fromRuntime(JsonKey);
  final _jsonIgnoreChecker = const TypeChecker.fromRuntime(JsonIgnore);

  @override
  Future<String?> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
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

  String buildFromJson(ClassElement cl) {
    final buffer = StringBuffer();
    final className = cl.displayName;

    var ctrs = <String>[];
    if (cl.constructors.isNotEmpty) {
      final ctr = cl.constructors.first;
      for (var par in ctr.parameters) {
        ctrs.add(par.declaration.name);
      }
    }

    buffer.writeln(
        '$className _\$${className}FromJson(Map<String, dynamic> json) => $className(');
    for (var f in cl.fields) {
      if (f.setter == null && !f.isFinal) continue;

      var name = f.name;
      if (!ctrs.contains(name)) continue;

      var isNullable = f.type.nullabilitySuffix == NullabilitySuffix.question;
      var type = f.type.getDisplayString(withNullability: isNullable);

      if (_jsonIgnoreChecker.hasAnnotationOfExact(f)) {
        final ann = _jsonIgnoreChecker.firstAnnotationOfExact(f)!;
        var ignore = ann.getField('ignore')?.toBoolValue() ?? false;
        var ignoreFromJson =
            ann.getField('ignoreFromJson')?.toBoolValue() ?? false;

        if (ignore || ignoreFromJson) continue;
      }

      final meta = '${className}Metadata.instance';
      buffer.writeln('${f.name} : json.value<$type>($meta.$name),');
    }
    buffer.writeln(');\n');
    return buffer.toString();
  }

  String buildToJson(ClassElement cl) {
    final className = cl.displayName;
    final buffer = StringBuffer();
    buffer.writeln(
        'Map<String, dynamic> _\$${className}ToJson($className instance) => {');
    for (var f in cl.fields) {
      if (f.setter == null &&
          !f.isFinal &&
          !_jsonKeyChecker.hasAnnotationOf(f)) {
        continue;
      }

      var name = f.name;
      var isNullable = f.type.nullabilitySuffix == NullabilitySuffix.question;

      if (_jsonIgnoreChecker.hasAnnotationOf(f)) {
        final ann = _jsonIgnoreChecker.firstAnnotationOfExact(f)!;
        var ignore = ann.getField('ignore')?.toBoolValue() ?? false;
        var ignoreToJson = ann.getField('ignoreToJson')?.toBoolValue() ?? false;

        if (ignore || ignoreToJson) continue;
      }

      if (_jsonKeyChecker.hasAnnotationOf(f)) {
        final ann = _jsonKeyChecker.firstAnnotationOfExact(f)!;
        name = ann.getField('name')!.toStringValue()!;
      }

      var suffix = '';
      if (!f.type.isDartCoreBool &&
          !f.type.isDartCoreDouble &&
          !f.type.isDartCoreInt &&
          !f.type.isDartCoreIterable &&
          !f.type.isDartCoreList &&
          !f.type.isDartCoreMap &&
          !f.type.isDartCoreNum &&
          !f.type.isDartCoreSet &&
          !f.type.isDartCoreString) {
        suffix = '${isNullable ? '?' : ''}.toJson()';
      }

      if (f.type.getDisplayString(withNullability: false) == 'DateTime') {
        suffix = '${isNullable ? '?' : ''}.toUtc().toIso8601String()';
      }

      final coreList = <String>[
        'List<String>',
        'List<int>',
        'List<double>',
        'List<num>',
        'List<bool>',
      ];

      if (f.type.isDartCoreList &&
          !coreList.contains(f.type.getDisplayString(withNullability: false))) {
        suffix = '${isNullable ? '?' : ''}.map((e) => e.toJson()).toList()';
      }

      final meta = '${className}Metadata.instance';
      buffer.writeln('$meta.${f.name} : instance.${f.name}$suffix,');
    }

    buffer.writeln('};\n');
    return buffer.toString();
  }

  String buildExtension(ClassElement cl) {
    final className = cl.displayName;
    final buffer = StringBuffer();

    buffer.writeln('extension ${className}JsonExtension on $className {');
    buffer.writeln(
        'Map<String, dynamic> toJson() => _\$${className}ToJson(this);');
    buffer.writeln(buildApply(cl));
    buffer.writeln(buildClone(cl));
    buffer.writeln(
        '${className}Metadata get metadata => ${className}Metadata.instance;');
    buffer.writeln('}');

    return buffer.toString();
  }

  String buildClassFields(ClassElement cl) {
    final className = cl.displayName;
    final buffer = StringBuffer();

    buffer.writeln('class ${className}Metadata {');
    buffer.writeln(
        'static final ${className}Metadata instance = ${className}Metadata._();');
    buffer.writeln('${className}Metadata._();');
    buffer.writeln(buildFields(cl));
    buffer.writeln('}');

    return buffer.toString();
  }

  String buildFields(ClassElement cl) {
    final buffer = StringBuffer();

    for (var f in cl.fields) {
      var name = f.name;
      if (f.hasOverride) continue;
      
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
    for (var f in cl.fields) {
      if (f.setter == null || f.isFinal) continue;
      var name = f.name;
      buffer.writeln('$name = other.$name;');
    }
    buffer.writeln('}');

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
