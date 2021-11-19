import 'package:model_factory/model_factory.dart';

part 'model_lain.g.dart';

@JsonSerializable()
class ModelA {
  @JsonKey('nama')
  final String nama;

  String? percobaan;
  String? alamatLengkap;

  ModelA({
    required this.nama,
  });

  factory ModelA.fromJson(Map<String, dynamic> map) => _$ModelAFromJson(map);
}

@JsonSerializable()
class ModelB extends ModelA {
  @JsonKey('alamat_lengkap')
  final String alamat;

  @JsonKey('telepon')
  final String? telepon;

  @JsonKey('model_a')
  final ModelA modelA;

  ModelB({
    required String nama,
    required this.alamat,
    this.telepon,
    required this.modelA,
  }) : super(
              nama: nama,
            );

  factory ModelB.fromJson(Map<String, dynamic> map) => _$ModelBFromJson(map);
}
