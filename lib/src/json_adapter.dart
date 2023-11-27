import 'package:model_factory/model_factory.dart';

abstract class JsonAdapter<T> {
  T fromJson(dynamic json);
  dynamic toJson(T instance);

  dynamic decode<E>(
    dynamic map,
    String key, {
    bool isList = false,
    bool isNullable = true,
    dynamic defaultValue,
  }) {
    return _tryDecode<E>(
      map,
      key,
      isList: isList,
      isNullable: isNullable,
      defaultValue: defaultValue,
    );
  }

  dynamic encode<E>(dynamic object, String key) {
    return _tryEncode<E>(object, key);
  }
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

dynamic _tryDecode<E>(
  dynamic map,
  String key, {
  bool isList = false,
  bool isNullable = true,
  dynamic defaultValue,
}) {
  try {
    final json = map[key] ?? defaultValue;
    if (json == null) {
      if (isNullable) {
        return null;
      }

      throw FieldParseException(
        innerException: 'Field is not nullable',
        key: key,
        value: json,
      );
    }

    if (isList && json is List) {
      if (json.isEmpty) {
        return <E>[];
      }

      final result = json.map((e) => _decode<E>(e)).toList().cast<E>();
      return result;
    }

    if (isList && json is! List) {
      throw FieldParseException(
        innerException:
            'Expected List<${E.runtimeType.toString()}> but got ${json.runtimeType}',
        key: key,
        value: json,
      );
    }

    final result = _decode<E>(json);
    if (isNullable) {
      return result;
    }

    if (result == null && defaultValue != null) {
      return defaultValue;
    }

    return result!;
  } catch (e) {
    throw FieldParseException(
      innerException: e,
      key: key,
      value: map[key] ?? map,
    );
  }
}

dynamic _encode<E>(E? object) {
  if (GetIt.I.isRegistered<JsonAdapter<E?>>()) {
    return GetIt.I<JsonAdapter<E?>>().toJson(object);
  }

  throw JsonAdapterNotRegisteredException(E);
}

dynamic _tryEncode<E>(dynamic object, String key) {
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
