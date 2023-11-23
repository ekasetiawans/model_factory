// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:model_factory/model_factory.dart';

part 't_model.g.dart';

@JsonSerializable()
class Parent {
  @JsonKey('id')
  final int id;
  @JsonKey('name')
  final String name;
  @JsonKey('address')
  final String? address;
  @JsonKey('hobbies')
  final List<String>? hobbies;

  const Parent({
    required this.id,
    required this.name,
    this.address,
    this.hobbies,
  });
  factory Parent.fromJson(Map<String, dynamic> map) => _$ParentFromJson(map);
}

@JsonSerializable()
class Kid {
  @JsonKey('id')
  final int id;
  @JsonKey('name')
  final String name;
  @JsonKey('father')
  final Parent father;
  @JsonKey('mother')
  final Parent? mother;
  @JsonKey('born_on')
  final DateTime born;

  const Kid({
    required this.id,
    required this.name,
    required this.father,
    this.mother,
    required this.born,
  });

  factory Kid.fromJson(Map<String, dynamic> map) => _$KidFromJson(map);
}
