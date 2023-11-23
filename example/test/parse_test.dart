import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:model_factory_example/json_registrant.dart';
import 'package:model_factory_example/models/t_model.dart';

void main() {
  setUp(() {
    JsonRegistrant.register();
  });

  test('test parse', () {
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
