import 'package:model_factory/model_factory.dart';

part 'model_lain.g.dart';

@JsonSerializable()
class ModelLain {
  @JsonKey('nama_lengkap')
  late String name;

  @JsonKey('address')
  late String address;

  @JsonKey('test')
  ModelYangLain? coba;
  ModelLain();

  factory ModelLain.fromJson(Map<String, dynamic> json) =>
      _$ModelLainFromJson(json);

  Map<String, dynamic> toJson() => _$ModelLainToJson(this);
}

@JsonSerializable()
class ModelYangLain {
  @JsonKey('nama')
  late String name;

  ModelYangLain();

  factory ModelYangLain.fromJson(Map<String, dynamic> json) =>
      _$ModelYangLainFromJson(json);

  Map<String, dynamic> toJson() => _$ModelYangLainToJson(this);
}
