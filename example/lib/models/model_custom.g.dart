// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_custom.dart';

// **************************************************************************
// Generator: ModelFactoryBuilder
// **************************************************************************

class ModelWithCustomJsonAdapter extends JsonAdapter<ModelWithCustom?> {
  static void register() {
    GetIt.I.registerSingleton<JsonAdapter<ModelWithCustom?>>(
        ModelWithCustomJsonAdapter());
    GetIt.I.registerFactoryParam<ModelWithCustom, dynamic, dynamic>(
        (json, _) => GetIt.I<JsonAdapter<ModelWithCustom?>>().fromJson(json)!);
  }

  @pragma('vm:entry-point')
  @override
  ModelWithCustom? fromJson(dynamic json) {
    if (json == null) return null;
    try {
      return ModelWithCustom(
        name: decode<String>(
          json,
          MyModelMetadata.instance.name,
          isNullable: false,
        )!,
        payment: _paymentFromJson(
          DeserializationInfo(
            key: ModelWithCustomMetadata.instance.payment,
            map: json,
            current: json[ModelWithCustomMetadata.instance.payment],
          ),
        ),
        shipment: decode<String>(
          json,
          ModelWithCustomMetadata.instance.shipment,
          isNullable: false,
        )!,
        customTo: decode<String>(
          json,
          ModelWithCustomMetadata.instance.customTo,
          isNullable: false,
        )!,
        tanggal: decode<DateTime>(
          json,
          ModelWithCustomMetadata.instance.tanggal,
          isNullable: false,
        )!,
        nullable: decode<String>(
          json,
          ModelWithCustomMetadata.instance.nullable,
          isNullable: true,
        ),
        converted: tryConvertFromJson(MyConverterModel(),
            json[ModelWithCustomMetadata.instance.converted]),
      );
    } on FieldParseException catch (e) {
      throw ModelParseException(
        innerException: e.innerException,
        key: e.key,
        className: 'ModelWithCustom',
      );
    }
  }

  @pragma('vm:entry-point')
  @override
  dynamic toJson(ModelWithCustom? instance) {
    if (instance == null) return null;
    return {
      MyModelMetadata.instance.name:
          encode<String>(instance.name, MyModelMetadata.instance.name)!,
      ModelWithCustomMetadata.instance.payment: encode<String>(
          instance.payment, ModelWithCustomMetadata.instance.payment)!,
      ModelWithCustomMetadata.instance.shipment: encode<String>(
          instance.shipment, ModelWithCustomMetadata.instance.shipment)!,
      ModelWithCustomMetadata.instance.customTo: _toJson(
        SerializationInfo(
          key: ModelWithCustomMetadata.instance.customTo,
          data: instance.customTo,
        ),
      ),
      ModelWithCustomMetadata.instance.tanggal: encode<DateTime>(
          instance.tanggal, ModelWithCustomMetadata.instance.tanggal)!,
      ModelWithCustomMetadata.instance.nullable: encode<String>(
          instance.nullable, ModelWithCustomMetadata.instance.nullable),
      ModelWithCustomMetadata.instance.converted:
          tryConvertToJson(MyConverterModel(), instance.converted),
      ModelWithCustomMetadata.instance.abc:
          encode<int>(instance.abc, ModelWithCustomMetadata.instance.abc)!,
    };
  }
}

_$ModelWithCustomFromJson(dynamic json) =>
    GetIt.I<JsonAdapter<ModelWithCustom?>>().fromJson(json)!;

extension ModelWithCustomJsonExtension on ModelWithCustom {
  @pragma('vm:entry-point')
  dynamic toJson() => GetIt.I<JsonAdapter<ModelWithCustom?>>().toJson(this);
  ModelWithCustom copyWith({
    String? name,
    String? payment,
    String? shipment,
    String? customTo,
    DateTime? tanggal,
    String? customAll,
    MyConvertedModel? converted,
    String? nullable,
  }) =>
      ModelWithCustom(
        name: name ?? this.name,
        payment: payment ?? this.payment,
        shipment: shipment ?? this.shipment,
        customTo: customTo ?? this.customTo,
        tanggal: tanggal ?? this.tanggal,
        customAll: customAll ?? this.customAll,
        converted: converted ?? this.converted,
        nullable: nullable ?? this.nullable,
      );

  void apply(ModelWithCustom other) {}

  ModelWithCustom clone() =>
      GetIt.I<JsonAdapter<ModelWithCustom?>>().fromJson(toJson()!)!;

  ModelWithCustomMetadata get metadata => ModelWithCustomMetadata.instance;
}

class ModelWithCustomMetadata {
  static final ModelWithCustomMetadata instance = ModelWithCustomMetadata._();
  ModelWithCustomMetadata._();
  final String payment = 'payment';
  final String shipment = 'shipment';
  final String customTo = 'customTo';
  final String tanggal = 'tanggal';
  final String nullable = 'nullable';
  final String customAll = 'customAll';
  final String converted = 'x_converted';
  final String abc = 'aaa';

  List<String> get fields => [
        'payment',
        'shipment',
        'customTo',
        'tanggal',
        'nullable',
        'customAll',
        'x_converted',
        'aaa',
      ];
  List<String> get allFields => [
        'name',
        'payment',
        'shipment',
        'customTo',
        'tanggal',
        'nullable',
        'customAll',
        'x_converted',
        'aaa',
      ];
  Map<String, String> get aliases => {};
  List<JsonField> get allJsonFields => [
        JsonField<ModelWithCustom>(
          name: 'payment',
          field: 'payment',
          alias: null,
          fieldType: String,
          fromSuper: false,
          handler: (instance) => instance.payment,
        ),
        JsonField<ModelWithCustom>(
          name: 'shipment',
          field: 'shipment',
          alias: null,
          fieldType: String,
          fromSuper: false,
          handler: (instance) => instance.shipment,
        ),
        JsonField<ModelWithCustom>(
          name: 'customTo',
          field: 'customTo',
          alias: null,
          fieldType: String,
          fromSuper: false,
          handler: (instance) => instance.customTo,
        ),
        JsonField<ModelWithCustom>(
          name: 'tanggal',
          field: 'tanggal',
          alias: null,
          fieldType: DateTime,
          fromSuper: false,
          handler: (instance) => instance.tanggal,
        ),
        JsonField<ModelWithCustom>(
          name: 'nullable',
          field: 'nullable',
          alias: null,
          fieldType: String,
          fromSuper: false,
          handler: (instance) => instance.nullable,
        ),
        JsonField<ModelWithCustom>(
          name: 'customAll',
          field: 'customAll',
          alias: null,
          fieldType: String,
          fromSuper: false,
          handler: (instance) => instance.customAll,
        ),
        JsonField<ModelWithCustom>(
          name: 'converted',
          field: 'x_converted',
          alias: null,
          fieldType: MyConvertedModel,
          fromSuper: false,
          handler: (instance) => instance.converted,
        ),
        JsonField<ModelWithCustom>(
          name: 'abc',
          field: 'aaa',
          alias: null,
          fieldType: int,
          fromSuper: false,
          handler: (instance) => instance.abc,
        ),
        JsonField<ModelWithCustom>(
          name: 'name',
          field: 'name',
          alias: null,
          fieldType: String,
          fromSuper: true,
          handler: (instance) => instance.name,
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
      case 'nullable':
        return instance.nullable;
      case 'customAll':
        return instance.customAll;
      case 'x_converted':
        return instance.converted;
      case 'aaa':
        return instance.abc;
      default:
        return null;
    }
  }
}
