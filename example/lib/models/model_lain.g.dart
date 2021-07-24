// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_lain.dart';

// **************************************************************************
// Generator: ModelFactoryBuilder
// **************************************************************************

ModelLain _$ModelLainFromJson(Map<String, dynamic> json) => ModelLain(
      name: json.value<String>('nama_lengkap'),
      address: json.value<String>('address'),
      coba: json.value<ModelYangLain?>('test'),
    );

Map<String, dynamic> _$ModelLainToJson(ModelLain instance) => {
      'nama_lengkap': instance.name,
      'address': instance.address,
      'test': instance.coba?.toJson(),
    };

ModelYangLain _$ModelYangLainFromJson(Map<String, dynamic> json) =>
    ModelYangLain(
      name: json.value<String>('nama'),
    );

Map<String, dynamic> _$ModelYangLainToJson(ModelYangLain instance) => {
      'nama': instance.name,
    };
