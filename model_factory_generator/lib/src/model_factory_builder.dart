import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
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
    final cl = element;
    final className = cl.displayName;

    var ctrs = <String>[];
    if (cl.constructors.isNotEmpty) {
      final ctr = cl.constructors.first;
      for (var par in ctr.parameters) {
        log.info(par.declaration.name);
        ctrs.add(par.declaration.name);
      }
    }

    buffer.writeln(
        '$className _\$${className}FromJson(Map<String, dynamic> json) => $className(');
    for (var f in cl.fields) {
      if (f.setter == null) continue;

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

      if (_jsonKeyChecker.hasAnnotationOfExact(f)) {
        final ann = _jsonKeyChecker.firstAnnotationOfExact(f)!;
        name = ann.getField('name')!.toStringValue()!;
      }

      buffer.writeln("${f.name} : json.value<$type>('$name'),");
    }
    buffer.writeln(');\n');

    buffer.writeln(
        'Map<String, dynamic> _\$${className}ToJson($className instance) => {');
    for (var f in cl.fields) {
      var name = f.name;
      var isNullable = f.type.nullabilitySuffix == NullabilitySuffix.question;

      if (_jsonIgnoreChecker.hasAnnotationOfExact(f)) {
        final ann = _jsonIgnoreChecker.firstAnnotationOfExact(f)!;
        var ignore = ann.getField('ignore')?.toBoolValue() ?? false;
        var ignoreToJson = ann.getField('ignoreToJson')?.toBoolValue() ?? false;

        if (ignore || ignoreToJson) continue;
      }

      if (_jsonKeyChecker.hasAnnotationOfExact(f)) {
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

      if (f.type.isDartCoreList) {
        suffix = '${isNullable ? '?' : ''}.map((e) => e.toJson()).toList()';
      }

      buffer.writeln("'$name' : instance.${f.name}$suffix,");
    }

    buffer.writeln('};\n');
    return DartFormatter().format(buffer.toString());
  }
}
