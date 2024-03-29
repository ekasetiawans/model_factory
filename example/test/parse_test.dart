import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:model_factory/model_factory.dart' hide JsonRegistrant;
import 'package:model_factory_example/json_registrant.dart';
import 'package:model_factory_example/models/t_model.dart';

void main() {
  setUpAll(() {
    JsonRegistrant.register();
  });

  test('test parse parent', () {
    final String data = '''
{
  "id" : 1,
  "name" : "John",
  "address" : "123 Main St",
  "hobbies" : ["reading", "writing"]
}
''';

    final parent = Parent.fromJson(json.decode(data));
    expect(parent.id, 1);
    expect(parent.name, 'John');
    expect(parent.address, '123 Main St');
    expect(parent.hobbies, ['reading', 'writing']);
  });

  test('test parse with GetIt', () {
    final String data = '''
{
  "id" : 1,
  "name" : "John",
  "address" : "123 Main St",
  "hobbies" : ["reading", "writing"]
}
''';

    final parent = GetIt.I.get<Parent>(param1: json.decode(data));
    expect(parent.id, 1);
    expect(parent.name, 'John');
    expect(parent.address, '123 Main St');
    expect(parent.hobbies, ['reading', 'writing']);
  });

  test('test parse kid', () {
    final String data = '''
{
  "id" : 1,
  "name" : "John",
  "father" : {
    "id" : 2,
    "name" : "Jack",
    "address" : "123 Main St"
  },
  "mother" : {
    "id" : 3,
    "name" : "Jill"
  },
  "born_on" : "2021-01-01T00:00:00.000Z"
}
''';

    final kid = Kid.fromJson(json.decode(data));
    expect(kid.id, 1);
    expect(kid.name, 'John');
    expect(kid.father.id, 2);
    expect(kid.father.name, 'Jack');
    expect(kid.father.address, '123 Main St');
    expect(kid.mother!.id, 3);
    expect(kid.mother!.name, 'Jill');
    expect(kid.born, DateTime.utc(2021, 1, 1).toLocal());
  });
}
