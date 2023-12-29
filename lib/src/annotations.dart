// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:model_factory/model_factory.dart';

class DeserializationInfo {
  final String key;
  final Map<String, dynamic> map;
  final Object? current;

  const DeserializationInfo({
    required this.key,
    required this.map,
    this.current,
  });
}

class SerializationInfo {
  final String key;
  final Object? data;

  const SerializationInfo({
    required this.key,
    this.data,
  });
}

class JsonKey<T> {
  final String name;
  final String? alias;

  final T Function(DeserializationInfo info)? fromJson;
  final Object? Function(SerializationInfo info)? toJson;
  final Type? withConverter;

  final dynamic defaultValue;
  final bool omitIfNull;

  const JsonKey(
    this.name, {
    this.fromJson,
    this.toJson,
    this.withConverter,
    this.alias,
    this.defaultValue,
    this.omitIfNull = true,
  });
}

class JsonIgnore {
  final bool ignoreToJson;
  final bool ignoreFromJson;

  const JsonIgnore({
    this.ignoreFromJson = true,
    this.ignoreToJson = true,
  });
}

class JsonSerializable {
  final Type? withConverter;
  const JsonSerializable({this.withConverter});
}

abstract class JsonConverter<T> {
  T fromJson(dynamic data);
  dynamic toJson(T model);
}

T tryConvertFromJson<T>(JsonConverter<T> converter, dynamic value,
    [dynamic defaultValue]) {
  try {
    return converter.fromJson(value);
  } catch (e) {
    return convertFromJson(value, defaultValue, false);
  }
}

dynamic tryConvertToJson<T>(JsonConverter<T> converter, T model) {
  try {
    return converter.toJson(model);
  } catch (e) {
    return convertToJson(model, false);
  }
}

class JsonField<T> {
  final String name;
  final String field;
  final String? alias;
  final Type fieldType;
  final bool fromSuper;
  final dynamic Function(T instance) _handler;

  const JsonField({
    required this.name,
    required this.field,
    this.alias,
    required this.fieldType,
    required this.fromSuper,
    required dynamic Function(T instance) handler,
  }) : _handler = handler;

  dynamic valueOf(T instance) {
    return _handler(instance);
  }
}
