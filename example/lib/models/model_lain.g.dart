// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_lain.dart';

// **************************************************************************
// Generator: ModelFactoryBuilder
// **************************************************************************

ModelA _$ModelAFromJson(Map<String, dynamic> json) => ModelA(
      nama: json.value<String>(ModelAMetadata.instance.nama),
    );

Map<String, dynamic> _$ModelAToJson(ModelA instance) => {
      ModelAMetadata.instance.nama: instance.nama,
    };

extension ModelAJsonExtension on ModelA {
  Map<String, dynamic> toJson() => _$ModelAToJson(this);
  void apply(ModelA other) {}

  ModelA clone() => _$ModelAFromJson(toJson());

  ModelAMetadata get metadata => ModelAMetadata.instance;
}

class ModelAMetadata {
  static final ModelAMetadata instance = ModelAMetadata._();
  ModelAMetadata._();
  final String nama = 'nama';
}

ModelB _$ModelBFromJson(Map<String, dynamic> json) => ModelB(
      nama: json.value<String>(ModelAMetadata.instance.nama),
      alamat: json.value<String>(ModelBMetadata.instance.alamat),
    );

Map<String, dynamic> _$ModelBToJson(ModelB instance) => {
      ModelAMetadata.instance.nama: instance.nama,
      ModelBMetadata.instance.alamat: instance.alamat,
    };

extension ModelBJsonExtension on ModelB {
  Map<String, dynamic> toJson() => _$ModelBToJson(this);
  void apply(ModelB other) {}

  ModelB clone() => _$ModelBFromJson(toJson());

  ModelBMetadata get metadata => ModelBMetadata.instance;
}

class ModelBMetadata {
  static final ModelBMetadata instance = ModelBMetadata._();
  ModelBMetadata._();
  final String alamat = 'alamat_lengkap';
}
