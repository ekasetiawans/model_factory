import 'package:model_factory/model_factory.dart';

part 'my_model.g.dart';

@JsonSerializable()
class MyModel {
  @JsonKey('name')
  final String name;
  MyModel({
    required this.name,
  });
  factory MyModel.fromJson(Map<String, dynamic> map) => _$MyModelFromJson(map);
}
