import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:model_factory_generator/src/model_factory_resolver.dart';
import 'package:path/path.dart';

const String templateHeader = '''
// ignore_for_file: type=lint

// This file is autogenerated by model_factory
// DO NOT MODIFY BY HAND
// To re-generate this file, run:
//    flutter pub run build_runner build
''';

class ModelFactoryGenerator extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    log.warning(buildStep.inputId.path);
    log.warning(dirname(buildStep.inputId.path));

    final files = <String, List<dynamic>>{};
    final glob = Glob(
      '${dirname(buildStep.inputId.path)}/**${ModelFactoryResolver.suffix}',
    );

    await for (final input in buildStep.findAssets(glob)) {
      files[input.path] = json.decode(await buildStep.readAsString(input))!;
    }
    if (files.isEmpty) return;

    final uris = <String, List<String>>{};
    for (final file in files.values) {
      for (final c in file) {
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
    contentBuffer.writeln(templateHeader);
    contentBuffer.writeln("import 'package:model_factory/model_factory.dart';");
    final imp = uris.keys.toList()..sort((a, b) => a.compareTo(b));
    for (final uri in imp) {
      final classes = uris[uri];
      if (classes!.isEmpty) continue;

      contentBuffer.writeln("import '$uri' as m${imp.indexOf(uri)};");
    }

    contentBuffer.writeln();
    contentBuffer.writeln('class JsonRegistrant {');
    contentBuffer.writeln('static void register(){');
    contentBuffer.writeln('registerDefaultAdapters();');
    for (final uri in imp) {
      final m = imp.indexOf(uri);
      final classes = uris[uri];
      if (classes!.isEmpty) continue;

      for (final c in classes) {
        contentBuffer.writeln(
          'GetIt.I.registerSingleton<JsonAdapter<m$m.$c?>>(m$m.${c}JsonAdapter());',
        );

        // contentBuffer.writeln(
        //   'registerJsonFactory<m$m.$c>((json) => m$m.$c.fromJson(json));',
        // );
        // contentBuffer.writeln(
        //   'registerJsonFactory<m$m.$c?>((json) => json == null ? null : m$m.$c.fromJson(json));',
        // );
        // contentBuffer.writeln(
        //   'registerToJson<m$m.$c>((e) => (e as m$m.$c).toJson());',
        // );
      }
    }
    contentBuffer.writeln('}}');

    // contentBuffer.writeln('void registerFactories(){');
    // for (final uri in imp) {
    //   final m = imp.indexOf(uri);
    //   final classes = uris[uri];
    //   if (classes!.isEmpty) continue;

    //   for (final c in classes) {
    //     contentBuffer.writeln(
    //       'registerJsonFactory<m$m.$c>((json) => m$m.$c.fromJson(json));',
    //     );
    //     contentBuffer.writeln(
    //       'registerJsonFactory<m$m.$c?>((json) => json == null ? null : m$m.$c.fromJson(json));',
    //     );
    //     contentBuffer.writeln(
    //       'registerToJson<m$m.$c>((e) => (e as m$m.$c).toJson());',
    //     );
    //   }
    // }
    // contentBuffer.write('}');

    final code = DartFormatter().format(contentBuffer.toString());
    final codeId = AssetId(
      buildStep.inputId.package,
      '${dirname(buildStep.inputId.path)}/$codeFile',
    );

    await buildStep.writeAsString(codeId, code);
  }

  static const codeFile = 'json_registrant.dart';
  static final _outputs = [codeFile];

  @override
  final buildExtensions = {r'$lib$': _outputs};
}
