import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:model_factory/model_factory.dart';
import 'package:source_gen/source_gen.dart';

class ModelFactoryResolver extends Builder {
  final _jsonKeyChecker = const TypeChecker.fromRuntime(JsonSerializable);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;
    final libReader = LibraryReader(await buildStep.inputLibrary);

    final elements = libReader.annotatedWith(_jsonKeyChecker);
    final entities = <Map<String, dynamic>>[];
    for (var c in elements) {
      entities.add({
        'uri': buildStep.inputId.uri.toString(),
        'class': c.element.displayName,
      });
    }

    await buildStep.writeAsString(
        buildStep.inputId.changeExtension(suffix), json.encode(entities));
  }

  static const suffix = '.model_factory.info';
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': [
          suffix,
        ],
      };
}
