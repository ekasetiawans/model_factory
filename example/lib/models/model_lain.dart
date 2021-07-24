import 'package:model_factory/model_factory.dart';

part 'model_lain.g.dart';

@JsonSerializable()
class ModelLain {
  @JsonKey('nama_lengkap')
  String name;

  @JsonKey('address')
  String address;

  @JsonKey('test')
  ModelYangLain? coba;

  ModelLain({
    this.name = '',
    required this.address,
    this.coba,
  });

  factory ModelLain.fromJson(Map<String, dynamic> json) =>
      _$ModelLainFromJson(json);

  Map<String, dynamic> toJson() => _$ModelLainToJson(this);
}

@JsonSerializable()
class ModelYangLain {
  @JsonKey('nama')
  String name;

  ModelYangLain({
    required this.name,
  });

  factory ModelYangLain.fromJson(Map<String, dynamic> json) =>
      _$ModelYangLainFromJson(json);

  Map<String, dynamic> toJson() => _$ModelYangLainToJson(this);
}
