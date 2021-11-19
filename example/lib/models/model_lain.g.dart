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
      ModelAMetadata.instance.percobaan: instance.percobaan,
      ModelAMetadata.instance.alamatLengkap: instance.alamatLengkap,
    };

extension ModelAJsonExtension on ModelA {
  Map<String, dynamic> toJson() => _$ModelAToJson(this);
  ModelA copyWith({
    String? nama,
    String? percobaan,
    String? alamatLengkap,
  }) =>
      ModelA(
        nama: nama ?? this.nama,
      )
        ..percobaan = percobaan ?? this.percobaan
        ..alamatLengkap = alamatLengkap ?? this.alamatLengkap;

  void apply(ModelA other) {
    percobaan = other.percobaan;
    alamatLengkap = other.alamatLengkap;
  }

  ModelA clone() => _$ModelAFromJson(toJson());

  ModelAMetadata get metadata => ModelAMetadata.instance;
}

class ModelAMetadata {
  static final ModelAMetadata instance = ModelAMetadata._();
  ModelAMetadata._();
  final String nama = 'nama';
  final String percobaan = 'percobaan';
  final String alamatLengkap = 'alamatLengkap';
}

ModelB _$ModelBFromJson(Map<String, dynamic> json) => ModelB(
      nama: json.value<String>(ModelAMetadata.instance.nama),
      alamat: json.value<String>(ModelBMetadata.instance.alamat),
      modelA: json.value<ModelA>(ModelBMetadata.instance.modelA),
    );

Map<String, dynamic> _$ModelBToJson(ModelB instance) => {
      ModelAMetadata.instance.nama: instance.nama,
      ModelAMetadata.instance.percobaan: instance.percobaan,
      ModelAMetadata.instance.alamatLengkap: instance.alamatLengkap,
      ModelBMetadata.instance.alamat: instance.alamat,
      ModelBMetadata.instance.modelA: instance.modelA.toJson(),
    };

extension ModelBJsonExtension on ModelB {
  Map<String, dynamic> toJson() => _$ModelBToJson(this);
  ModelB copyWith({
    String? nama,
    String? alamat,
    ModelA? modelA,
  }) =>
      ModelB(
        nama: nama ?? this.nama,
        alamat: alamat ?? this.alamat,
        modelA: modelA ?? this.modelA,
      );

  void apply(ModelB other) {}

  ModelB clone() => _$ModelBFromJson(toJson());

  ModelBMetadata get metadata => ModelBMetadata.instance;
}

class ModelBMetadata {
  static final ModelBMetadata instance = ModelBMetadata._();
  ModelBMetadata._();
  final String alamat = 'alamat_lengkap';
  final String modelA = 'model_a';
}
