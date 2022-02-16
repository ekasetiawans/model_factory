// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_custom.dart';

// **************************************************************************
// Generator: ModelFactoryBuilder
// **************************************************************************

ModelWithCustom _$ModelWithCustomFromJson(
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
      customAll: _paymentFromJson(
        DeserializationInfo(
          key: ModelWithCustomMetadata.instance.customAll,
          map: json,
          current: json[ModelWithCustomMetadata.instance.customAll],
        ),
      ),
    );
  } on FieldParseException catch (e) {
    throw ModelParseException(
      innerException: e.innerException,
      key: e.key,
      className: 'ModelWithCustom',
    );
  }
}

Map<String, dynamic> _$ModelWithCustomToJson(
  ModelWithCustom instance,
) {
  return {
    ModelWithCustomMetadata.instance.payment: instance.payment,
    ModelWithCustomMetadata.instance.shipment: instance.shipment,
    ModelWithCustomMetadata.instance.customTo: _toJson(
      SerializationInfo(
        key: ModelWithCustomMetadata.instance.customTo,
        data: instance.customTo,
      ),
    ),
    ModelWithCustomMetadata.instance.customAll: _toJson(
      SerializationInfo(
        key: ModelWithCustomMetadata.instance.customAll,
        data: instance.customAll,
      ),
    ),
  };
}

extension ModelWithCustomJsonExtension on ModelWithCustom {
  Map<String, dynamic> toJson() => _$ModelWithCustomToJson(this);
  ModelWithCustom copyWith({
    String? payment,
    String? shipment,
    String? customTo,
    String? customAll,
  }) =>
      ModelWithCustom(
        payment: payment ?? this.payment,
        shipment: shipment ?? this.shipment,
        customTo: customTo ?? this.customTo,
        customAll: customAll ?? this.customAll,
      );

  void apply(ModelWithCustom other) {}

  ModelWithCustom clone() => _$ModelWithCustomFromJson(toJson());

  ModelWithCustomMetadata get metadata => ModelWithCustomMetadata.instance;
}

class ModelWithCustomMetadata {
  static final ModelWithCustomMetadata instance = ModelWithCustomMetadata._();
  static bool _isRegistered = false;
  static void registerFactory() {
    if (_isRegistered) return;
    _isRegistered = true;
    registerJsonFactory((json) => ModelWithCustom.fromJson(json));
  }

  ModelWithCustomMetadata._();
  final String payment = 'payment';
  final String shipment = 'shipment';
  final String customTo = 'customTo';
  final String customAll = 'customAll';
}
