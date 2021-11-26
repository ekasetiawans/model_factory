// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_lain.dart';

// **************************************************************************
// Generator: ModelFactoryBuilder
// **************************************************************************

ModelA _$ModelAFromJson(
  Map<String, dynamic> json,
) {
  return ModelA(
    nama: json.value<String>(
      ModelAMetadata.instance.nama,
    ),
  );
}

Map<String, dynamic> _$ModelAToJson(
  ModelA instance,
) {
  return {
    ModelAMetadata.instance.nama: instance.nama,
    ModelAMetadata.instance.percobaan: instance.percobaan,
    ModelAMetadata.instance.alamatLengkap: instance.alamatLengkap,
  };
}

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
  static bool _isRegistered = false;
  static void registerFactory() {
    if (_isRegistered) return;
    _isRegistered = true;
    registerJsonFactory((json) => ModelA.fromJson(json));
  }

  ModelAMetadata._();
  final String nama = 'nama';
  final String percobaan = 'percobaan';
  final String alamatLengkap = 'alamatLengkap';
}

ModelB _$ModelBFromJson(
  Map<String, dynamic> json,
) {
  ModelAMetadata.registerFactory();
  return ModelB(
    nama: json.value<String>(
      ModelAMetadata.instance.nama,
    ),
    alamat: json.value<String>(
      ModelBMetadata.instance.alamat,
    ),
    telepon: json.value<String?>(
      ModelBMetadata.instance.telepon,
    ),
    modelA: json.value<ModelA>(
      ModelBMetadata.instance.modelA,
    ),
    models: json.value<List<ModelA>>(
      ModelBMetadata.instance.models,
    ),
  );
}

Map<String, dynamic> _$ModelBToJson(
  ModelB instance,
) {
  ModelAMetadata.registerFactory();
  return {
    ModelAMetadata.instance.nama: instance.nama,
    ModelAMetadata.instance.percobaan: instance.percobaan,
    ModelAMetadata.instance.alamatLengkap: instance.alamatLengkap,
    ModelBMetadata.instance.alamat: instance.alamat,
    ModelBMetadata.instance.telepon: instance.telepon,
    ModelBMetadata.instance.modelA: instance.modelA.toJson(),
    ModelBMetadata.instance.models:
        instance.models.map((e) => e.toJson()).toList(),
  };
}

extension ModelBJsonExtension on ModelB {
  Map<String, dynamic> toJson() => _$ModelBToJson(this);
  ModelB copyWith({
    String? nama,
    String? alamat,
    String? telepon,
    ModelA? modelA,
    List<ModelA>? models,
  }) =>
      ModelB(
        nama: nama ?? this.nama,
        alamat: alamat ?? this.alamat,
        telepon: telepon ?? this.telepon,
        modelA: modelA ?? this.modelA,
        models: models ?? this.models,
      );

  void apply(ModelB other) {}

  ModelB clone() => _$ModelBFromJson(toJson());

  ModelBMetadata get metadata => ModelBMetadata.instance;
}

class ModelBMetadata {
  static final ModelBMetadata instance = ModelBMetadata._();
  static bool _isRegistered = false;
  static void registerFactory() {
    if (_isRegistered) return;
    _isRegistered = true;
    registerJsonFactory((json) => ModelB.fromJson(json));
  }

  ModelBMetadata._();
  final String alamat = 'alamat_lengkap';
  final String telepon = 'telepon';
  final String modelA = 'model_a';
  final String models = 'modelsss';
}
