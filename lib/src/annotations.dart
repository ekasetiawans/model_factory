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

  final T Function(DeserializationInfo info)? fromJson;
  final Object? Function(SerializationInfo info)? toJson;

  const JsonKey(
    this.name, {
    this.fromJson,
    this.toJson,
  });
}

class JsonIgnore {
  final bool ignore;
  final bool ignoreToJson;
  final bool ignoreFromJson;

  const JsonIgnore({
    this.ignore = false,
    this.ignoreFromJson = false,
    this.ignoreToJson = false,
  });
}

class JsonSerializable {
  const JsonSerializable();
}
