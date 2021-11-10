import 'package:model_factory/model_factory.dart';

part 'model_lain.g.dart';

@JsonSerializable()
class ModelA {
  @JsonKey('nama')
  final String nama;

  ModelA({
    required this.nama,
  });

  factory ModelA.fromJson(Map<String, dynamic> map) => _$ModelAFromJson(map);
}

@JsonSerializable()
class ModelB extends ModelA {
  @JsonKey('alamat_lengkap')
  final String alamat;

  ModelB({
    required this.alamat,
    required String nama,
  }) : super(
          nama: nama,
        );

  factory ModelB.fromJson(Map<String, dynamic> map) => _$ModelBFromJson(map);
}
