// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  const JsonKey(
    this.name, {
    this.fromJson,
    this.toJson,
    this.withConverter,
    this.alias,
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

class JsonField<T> {
  final String name;
  final String field;
  final String? alias;
  final Type fieldType;
  final bool fromSuper;
  final dynamic Function(T instance) valueOf;

  const JsonField({
    required this.name,
    required this.field,
    this.alias,
    required this.fieldType,
    required this.fromSuper,
    required this.valueOf,
  });
}
