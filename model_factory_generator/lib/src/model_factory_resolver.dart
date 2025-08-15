import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:model_factory/model_factory.dart';
import 'package:source_gen/source_gen.dart';

class ModelFactoryResolver extends Builder {
  final _jsonKeyChecker =
      const TypeChecker.typeNamed(JsonSerializable, inPackage: 'model_factory');

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;
    final libReader = LibraryReader(await buildStep.inputLibrary);

    final elements = libReader.annotatedWith(_jsonKeyChecker);
    final entities = <Map<String, dynamic>>[];
    for (final c in elements) {
      if (c.element is ClassElement2) {
        final classElement = c.element as ClassElement2;

        final serializable =
            _jsonKeyChecker.firstAnnotationOfExact(classElement)!;
        final isWithConverter =
            serializable.getField('withConverter')?.toTypeValue() != null;
        if (isWithConverter) {
          continue;
        }

        entities.add({
          'uri': buildStep.inputId.uri.toString(),
          'class': classElement.displayName,
        });
      }
    }

    await buildStep.writeAsString(
      buildStep.inputId.changeExtension(suffix),
      json.encode(entities),
    );
  }

  static const suffix = '.model_factory.json';
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': [
          suffix,
        ],
      };
}
