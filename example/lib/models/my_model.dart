import 'package:model_factory/model_factory.dart';

part 'my_model.g.dart';

@JsonSerializable()
class MyModel {
  @JsonKey('name')
  final String name;

  @JsonKey('dynamic')
  final dynamic dinamic;

  MyModel({
    required this.name,
    required this.dinamic,
  });

  factory MyModel.fromJson(Map<String, dynamic> map) => _$MyModelFromJson(map);
}

@JsonSerializable()
class ModelWithoutConstructor {
  const ModelWithoutConstructor();

  factory ModelWithoutConstructor.fromJson(Map<String, dynamic> map) =>
      _$ModelWithoutConstructorFromJson(map);
}
