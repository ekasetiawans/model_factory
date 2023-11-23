import 'package:model_factory/model_factory.dart';

abstract class JsonAdapter<T> {
  T fromJson(dynamic value);
  dynamic toJson(T object);
}

class JsonAdapterNotRegisteredException implements Exception {
  final Type type;

  JsonAdapterNotRegisteredException(this.type);

  @override
  String toString() {
    return 'JsonAdapterNotRegisteredException: JsonAdapter<$type> is not registered';
  }
}

dynamic _decode<E>(dynamic json) {
  if (GetIt.I.isRegistered<JsonAdapter<E?>>()) {
    return GetIt.I<JsonAdapter<E?>>().fromJson(json);
  }

  throw JsonAdapterNotRegisteredException(E);
}

dynamic tryDecode<E>(dynamic map, String key) {
  try {
    final json = map[key];
    if (json == null) return null;

    if (json is List) {
      return json.map((e) => _decode(e)).toList().cast<E>();
    }

    return _decode<E>(json);
  } catch (e) {
    throw FieldParseException(
      innerException: e,
      key: key,
    );
  }
}

dynamic _encode<E>(E? object) {
  if (GetIt.I.isRegistered<JsonAdapter<E?>>()) {
    return GetIt.I<JsonAdapter<E?>>().toJson(object);
  }

  throw JsonAdapterNotRegisteredException(E);
}

dynamic tryEncode<E>(dynamic object, String key) {
  try {
    if (object == null) return null;

    if (object is List) {
      return object.map((e) => _encode<E>(e)).toList();
    }

    return _encode<E>(object);
  } catch (e) {
    throw FieldParseException(
      innerException: e,
      key: key,
    );
  }
}
