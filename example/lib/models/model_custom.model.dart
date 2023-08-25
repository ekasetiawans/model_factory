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
      name: json.value<String>(
        MyModelMetadata.instance.name,
      ),
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
ModelWithCustom _$ModelWithCustomFromJson(Map<String, dynamic> json) =>
    defaultModelWithCustomDeserializer(json);

typedef ModelWithCustomJsonSerializer = Map<String, dynamic> Function(
    ModelWithCustom instance);
final ModelWithCustomJsonSerializer defaultModelWithCustomSerializer =
    (ModelWithCustom instance) {
  return {
    MyModelMetadata.instance.name: instance.name,
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

Map<String, dynamic> _$ModelWithCustomToJson(ModelWithCustom instance) =>
    defaultModelWithCustomSerializer(instance);

extension ModelWithCustomJsonExtension on ModelWithCustom {
  Map<String, dynamic> toJson() => _$ModelWithCustomToJson(this);
  ModelWithCustom copyWith({
    String? name,
    String? payment,
    String? shipment,
    String? customTo,
    DateTime? tanggal,
    String? customAll,
    MyConvertedModel? converted,
  }) =>
      ModelWithCustom(
        name: name ?? this.name,
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

  List<String> get fields => [
        'payment',
        'shipment',
        'customTo',
        'tanggal',
        'customAll',
        'converted',
      ];
  List<String> get allFields => [
        'name',
        'payment',
        'shipment',
        'customTo',
        'tanggal',
        'customAll',
        'converted',
      ];
  Map<String, String> get aliases => {};
  List<JsonField> get allJsonFields => [
        JsonField<ModelWithCustom>(
          name: 'payment',
          field: 'payment',
          alias: null,
          fieldType: String,
          fromSuper: false,
          valueOf: (instance) => instance.payment,
        ),
        JsonField<ModelWithCustom>(
          name: 'shipment',
          field: 'shipment',
          alias: null,
          fieldType: String,
          fromSuper: false,
          valueOf: (instance) => instance.shipment,
        ),
        JsonField<ModelWithCustom>(
          name: 'customTo',
          field: 'customTo',
          alias: null,
          fieldType: String,
          fromSuper: false,
          valueOf: (instance) => instance.customTo,
        ),
        JsonField<ModelWithCustom>(
          name: 'tanggal',
          field: 'tanggal',
          alias: null,
          fieldType: DateTime,
          fromSuper: false,
          valueOf: (instance) => instance.tanggal,
        ),
        JsonField<ModelWithCustom>(
          name: 'customAll',
          field: 'customAll',
          alias: null,
          fieldType: String,
          fromSuper: false,
          valueOf: (instance) => instance.customAll,
        ),
        JsonField<ModelWithCustom>(
          name: 'converted',
          field: 'converted',
          alias: null,
          fieldType: MyConvertedModel,
          fromSuper: false,
          valueOf: (instance) => instance.converted,
        ),
        JsonField<ModelWithCustom>(
          name: 'name',
          field: 'name',
          alias: null,
          fieldType: String,
          fromSuper: true,
          valueOf: (instance) => instance.name,
        ),
      ];
  dynamic valueOf(ModelWithCustom instance, String fieldName) {
    switch (fieldName) {
      case 'name':
        return instance.name;
      case 'payment':
        return instance.payment;
      case 'shipment':
        return instance.shipment;
      case 'customTo':
        return instance.customTo;
      case 'tanggal':
        return instance.tanggal;
      case 'customAll':
        return instance.customAll;
      case 'converted':
        return instance.converted;
      default:
        return null;
    }
  }
}
