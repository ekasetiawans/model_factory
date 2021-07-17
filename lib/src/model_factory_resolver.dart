import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class ModelFactoryResolver extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;
    final libReader = LibraryReader(await buildStep.inputLibrary);

    final entities = <Map<String, dynamic>>[];
    for (var c in libReader.classes) {
      if (c.source.contents.data.contains('${c.displayName}.fromJson')) {
        entities.add({
          'uri': buildStep.inputId.uri.toString(),
          'class': c.displayName,
        });
      }
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
