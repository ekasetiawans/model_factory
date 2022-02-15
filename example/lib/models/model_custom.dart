import 'package:model_factory/model_factory.dart';

part 'model_custom.g.dart';

@JsonSerializable()
class ModelWithCustom {
  @JsonKey<String>('payment', fromJson: _paymentFromJson)
  final String payment;

  @JsonKey('shipment')
  final String shipment;

  @JsonKey<String>('customTo', toJson: _toJson)
  final String customTo;

  @JsonKey<String>(
    'customAll',
    fromJson: _paymentFromJson,
    toJson: _toJson,
  )
  final String customAll;

  const ModelWithCustom({
    required this.payment,
    required this.shipment,
    required this.customTo,
    required this.customAll,
  });

  factory ModelWithCustom.fromJson(Map<String, dynamic> map) =>
      _$ModelWithCustomFromJson(map);
}

String _paymentFromJson(DeserializationInfo info) {
  return 'hello world';
}

Map<String, dynamic> _toJson(SerializationInfo info) {
  return {
    'hello': 'world',
  };
}
