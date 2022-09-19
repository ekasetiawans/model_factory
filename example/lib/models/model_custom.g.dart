// ignore_for_file: type=lint

// This file is autogenerated by model_factory
// DO NOT MODIFY BY HAND
// To re-generate this file, run:
//    flutter pub run build_runner build

part of 'model_custom.dart';

// **************************************************************************
// Generator: ModelFactoryBuilder
// **************************************************************************

typedef ModelWithCustomJsonDeserializer = ModelWithCustom Function(
    Map<String, dynamic> json);
final ModelWithCustomJsonDeserializer defaultModelWithCustomDeserializer = (
  Map<String, dynamic> json,
) {
  try {
    return ModelWithCustom(
      payment: _paymentFromJson(
        DeserializationInfo(
          key: ModelWithCustomMetadata.instance.payment,
          map: json,
          current: json[ModelWithCustomMetadata.instance.payment],
        ),
      ),
      shipment: json.value<String>(
        ModelWithCustomMetadata.instance.shipment,
      ),
      customTo: json.value<String>(
        ModelWithCustomMetadata.instance.customTo,
      ),
      tanggal: json.value<DateTime>(
        ModelWithCustomMetadata.instance.tanggal,
      ),
      converted: MyConverterModel()
          .fromJson(json[ModelWithCustomMetadata.instance.converted]),
    );
  } on FieldParseException catch (e) {
    throw ModelParseException(
      innerException: e.innerException,
      key: e.key,
      className: 'ModelWithCustom',
    );
  }
};
final ModelWithCustomJsonDeserializer _$ModelWithCustomFromJson =
    defaultModelWithCustomDeserializer;

typedef ModelWithCustomJsonSerializer = Map<String, dynamic> Function(
    ModelWithCustom instance);
final ModelWithCustomJsonSerializer defaultModelWithCustomSerializer =
    (ModelWithCustom instance) {
  return {
    ModelWithCustomMetadata.instance.payment: instance.payment,
    ModelWithCustomMetadata.instance.shipment: instance.shipment,
    ModelWithCustomMetadata.instance.customTo: _toJson(
      SerializationInfo(
        key: ModelWithCustomMetadata.instance.customTo,
        data: instance.customTo,
      ),
    ),
    ModelWithCustomMetadata.instance.tanggal:
        instance.tanggal.toUtc().toIso8601String(),
    ModelWithCustomMetadata.instance.converted:
        MyConverterModel().toJson(instance.converted),
  };
};

final ModelWithCustomJsonSerializer _$ModelWithCustomToJson =
    defaultModelWithCustomSerializer;

extension ModelWithCustomJsonExtension on ModelWithCustom {
  Map<String, dynamic> toJson() => _$ModelWithCustomToJson(this);
  ModelWithCustom copyWith({
    String? payment,
    String? shipment,
    String? customTo,
    DateTime? tanggal,
    String? customAll,
    MyConvertedModel? converted,
  }) =>
      ModelWithCustom(
        payment: payment ?? this.payment,
        shipment: shipment ?? this.shipment,
        customTo: customTo ?? this.customTo,
        tanggal: tanggal ?? this.tanggal,
        customAll: customAll ?? this.customAll,
        converted: converted ?? this.converted,
      );

  void apply(ModelWithCustom other) {}

  ModelWithCustom clone() => _$ModelWithCustomFromJson(toJson());

  ModelWithCustomMetadata get metadata => ModelWithCustomMetadata.instance;
}

class ModelWithCustomMetadata {
  static final ModelWithCustomMetadata instance = ModelWithCustomMetadata._();
  ModelWithCustomMetadata._();
  final String payment = 'payment';
  final String shipment = 'shipment';
  final String customTo = 'customTo';
  final String tanggal = 'tanggal';
  final String customAll = 'customAll';
  final String converted = 'converted';
}
