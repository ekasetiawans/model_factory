import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:model_factory/src/model_factory_resolver.dart';
import 'package:path/path.dart';

class ModelFactoryGenerator extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    log.warning(buildStep.inputId.path);
    log.warning(dirname(buildStep.inputId.path));

    final files = <String, List<dynamic>>{};
    final glob = Glob(
        dirname(buildStep.inputId.path) + '/**' + ModelFactoryResolver.suffix);

    await for (final input in buildStep.findAssets(glob)) {
      files[input.path] = json.decode(await buildStep.readAsString(input))!;
    }
    if (files.isEmpty) return;

    final uris = <String, List<String>>{};
    for (var file in files.values) {
      for (var c in file) {
        final uri = c['uri'];
        final className = c['class'];
        if (uris.containsKey(uri)) {
          final l = uris[uri];
          l!.add(className);
        } else {
          uris[uri] = [className];
        }
      }
    }

    final contentBuffer = StringBuffer();
    contentBuffer.writeln("import 'package:model_factory/model_factory.dart';");
    final imp = uris.keys.toList();
    for (var uri in imp) {
      final classes = uris[uri];
      if (classes!.isEmpty) continue;

      contentBuffer.writeln("import '$uri' as m${imp.indexOf(uri)};");
    }

    contentBuffer.writeln();
    contentBuffer.writeln('void registerFactories(){');
    for (var uri in imp) {
      final m = imp.indexOf(uri);
      final classes = uris[uri];
      if (classes!.isEmpty) continue;

      for (var c in classes) {
        contentBuffer
            .writeln('registerJsonFactory((json) => m$m.$c.fromJson(json));');
      }
    }
    contentBuffer.write('}');

    final code = DartFormatter().format(contentBuffer.toString());
    final codeId = AssetId(
      buildStep.inputId.package,
      dirname(buildStep.inputId.path) + '/' + codeFile,
    );

    await buildStep.writeAsString(codeId, code);
  }

  static final codeFile = 'model_factories.g.dart';
  static final _outputs = [codeFile];

  @override
  final buildExtensions = {r'$lib$': _outputs};
}
