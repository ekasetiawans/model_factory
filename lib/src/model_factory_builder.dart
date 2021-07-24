import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:model_factory/model_factory.dart';
import 'package:source_gen/source_gen.dart';

class ModelFactoryBuilder extends Generator {
  final _typeChecker = TypeChecker.fromRuntime(JsonSerializable);
  final _fieldChecker = const TypeChecker.fromRuntime(JsonKey);

  @override
  Future<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final annotated = library.annotatedWith(_typeChecker);
    if (annotated.isEmpty) return null;

    final buffer = StringBuffer();

    for (var annotated in annotated) {
      final element = annotated.element;
      if (element is ClassElement) {
        final cl = element;
        final name = cl.displayName;
        buffer.writeln(
            '$name _\$${name}FromJson(Map<String, dynamic> json) => $name()');
        for (var f in cl.fields) {
          var name = f.name;
          var isNullable =
              f.type.nullabilitySuffix == NullabilitySuffix.question;
          var type = f.type.getDisplayString(withNullability: isNullable);

          if (_fieldChecker.hasAnnotationOfExact(f)) {
            name = _fieldChecker
                .firstAnnotationOfExact(f)!
                .getField('name')!
                .toStringValue()!;
          }

          buffer.writeln("..${f.name} = json.value<$type>('$name')");
        }
        buffer.writeln(';\n');

        buffer.writeln(
            'Map<String, dynamic> _\$${name}ToJson($name instance) => {');
        for (var f in cl.fields) {
          var name = f.name;
          var isNullable =
              f.type.nullabilitySuffix == NullabilitySuffix.question;

          if (_fieldChecker.hasAnnotationOfExact(f)) {
            name = _fieldChecker
                .firstAnnotationOfExact(f)!
                .getField('name')!
                .toStringValue()!;
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

          buffer.writeln("'$name' : instance.${f.name}$suffix,");
        }

        buffer.writeln('};\n');
      }
    }

    return buffer.toString();
  }
}
