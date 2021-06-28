import 'dart:io';

import 'package:yaml/yaml.dart';

final dir = Directory('lib');
Future<void> main() async {
  var pubspec = File('pubspec.yaml');
  final pubspecContent = pubspec.readAsStringSync();
  final pubspecYaml = loadYaml(pubspecContent);
  final packageName = pubspecYaml['name'];

  var registration = 'void registerFactories(){\n';
  var needImports = <String>[];

  for (var item in dir.listSync(recursive: true)) {
    if (item is File && item.path.toLowerCase().endsWith('.dart')) {
      final content = item.readAsStringSync();
      final lines = content.split('\n');

      var inum = needImports.length + 1;

      var found = false;
      for (var line in lines) {
        final r = RegExp(r'class (.+) {');
        final m = r.firstMatch(line.trim());
        if (m == null) continue;

        final className = m.group(1);
        if (content.contains('$className.fromJson(')) {
          registration +=
              '\tregisterJsonFactory((json) => model$inum.$className.fromJson(json));\n';
          found = true;
        }
      }

      final filePath = item.path.substring(4);
      if (found && !needImports.contains(filePath)) {
        needImports
            .add("import 'package:$packageName/$filePath' as model$inum;");
      }
    }
  }

  registration += '}';

  final factoryFile = File('lib/model_factories.g.dart');
  final importString = "import 'package:model_factory/model_factory.dart';";
  final imports = needImports.fold<String>(
      '', (previousValue, element) => previousValue += element + '\n');

  final content = '$importString\n\n$imports\n\n$registration';
  factoryFile.writeAsStringSync(content, flush: true);
}
