class JsonKey {
  final String name;
  const JsonKey(this.name);
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
