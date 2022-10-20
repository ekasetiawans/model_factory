// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  @JsonKey('tanggal')
  final DateTime tanggal;

  @JsonKey<String>(
    'customAll',
    fromJson: _paymentFromJson,
    toJson: _toJson,
  )
  @JsonIgnore()
  final String customAll;

  @JsonKey('converted', withConverter: MyConverterModel)
  final MyConvertedModel converted;

  const ModelWithCustom({
    required this.payment,
    required this.shipment,
    required this.customTo,
    required this.tanggal,
    this.customAll = 'Test',
    required this.converted,
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

class MyConvertedModel {
  final String nama;

  MyConvertedModel({
    required this.nama,
  });
}

class MyConverterModel extends JsonConverter<MyConvertedModel> {
  @override
  MyConvertedModel fromJson(dynamic data) {
    return MyConvertedModel(nama: data['nama']);
  }

  @override
  toJson(MyConvertedModel model) {
    return {};
  }
}
