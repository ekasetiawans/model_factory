import 'dart:async';
import 'dart:convert';

import 'package:model_factory/model_factory.dart';

extension JsonExt on JsonCodec {
  E? decodeAs<E>(String source) {
    if (source.startsWith('[')) {
      throw Exception('use decodeAsList instead');
    }

    if (source.startsWith('{')) {
      final Map<String, dynamic> map = decode(source);
      return map.convert<E>();
    }

    return decode(source) as E;
  }

  E? decodeAsList<E>(String source) {
    if (source.startsWith('{')) {
      throw Exception('use decodeAs instead');
    }

    if (source.startsWith('[')) {
      final List list = decode(source);
      return list.convert<E>();
    }

    return null;
  }
}

extension JsonMap on Map<String, dynamic> {
  String? string(String key, {String? defaultValue}) {
    if (containsKey(key)) {
      if (this[key] is String) {
        return this[key];
      } else if (this[key] == null) {
        return defaultValue ?? _defaultValues[String];
      }
    }

    return defaultValue;
  }

  num number(String key, {num defaultValue = 0}) {
    if (containsKey(key)) {
      if (this[key] is num) {
        return this[key];
      }

      if (this[key] is String) {
        return num.tryParse(this[key]) ?? defaultValue;
      }

      if (this[key] == null) {
        return defaultValue;
      }
    }

    return defaultValue;
  }

  bool boolean(String key, {bool defaultValue = false}) {
    if (containsKey(key)) {
      if (this[key] is bool) {
        return this[key];
      }

      if (this[key] is String) {
        return (this[key] == '1') || (this[key] == 'true');
      }

      if (this[key] is int) {
        return this[key] == 1;
      }

      if (this[key] == null) {
        return defaultValue;
      }
    }

    return defaultValue;
  }

  DateTime? dateTime(String key) {
    if (containsKey(key)) {
      if (this[key] is String) {
        String str = this[key];
        if (str.length > 10 && !str.contains('Z') && !str.contains('+')) {
          str += 'Z';
        }

        return DateTime.parse(str).toLocal();
      }

      if (this[key] == null) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
    }

    return null;
  }

  List<T> array<T>(String key, T Function(dynamic) f) {
    if (containsKey(key) && this[key] is List) {
      return (this[key] as List).map<T>(f).toList();
    }

    return <T>[];
  }

  E value<E>(String key, {E? defaultValue}) {
    try {
      if (E == dynamic) {
        return this[key];
      }

      if (!containsKey(key)) {
        if (defaultValue != null) return defaultValue;
        return null as E;
      }

      if (this[key] == null) {
        if (defaultValue != null) return defaultValue;
        return null as E;
      }

      if (this[key] is Map && (this[key] as Map).isEmpty) {
        if (defaultValue != null) return defaultValue;
        return null as E;
      }

      if (_converters.containsKey(E)) {
        final converter = _converters[E] as JsonConverter<E>;
        return converter.fromJson(this[key]);
      }

      if (_factories.containsKey(E)) {
        return _factories[E](this[key]);
      }

      if (_factories.containsKey(_typeOf<E>())) {
        return _factories[_typeOf<E>()](this[key]);
      }

      if (E == String) {
        return string(key) as E;
      }

      if (E == int) {
        return number(key).toInt() as E;
      }

      if (E == double) {
        return number(key).toDouble() as E;
      }

      if (E == num) {
        return number(key) as E;
      }

      if (E == DateTime) {
        return dateTime(key) as E;
      }

      if (E == bool) {
        return boolean(key) as E;
      }

      if (E == _typeOf<String?>()) {
        return string(key) as E;
      }

      if (E == _typeOf<int?>()) {
        return number(key).toInt() as E;
      }

      if (E == _typeOf<double?>()) {
        return number(key).toDouble() as E;
      }

      if (E == _typeOf<num?>()) {
        return number(key) as E;
      }

      if (E == _typeOf<DateTime?>()) {
        return dateTime(key) as E;
      }

      if (E == _typeOf<bool?>()) {
        return boolean(key) as E;
      }

      if (E == _typeOf<List>()) {
        return (this[key] as List).convert();
      }

      if (this[key] is List) {
        return (this[key] as List).convert();
      }

      if (this[key] is Map<String, dynamic>) {
        return (this[key] as Map<String, dynamic>).convert();
      }
    } catch (e) {
      throw FieldParseException(
        key: key,
        innerException: e,
      );
    }

    return this[key] as E;
  }

  E? convert<E>() {
    if (_factories.containsKey(E)) {
      return _factories[E](cast<String, dynamic>());
    }

    return null;
  }

  E valueOf<E>(String key, {E? defaultValue}) {
    try {
      return convertFromJson<E>(this[key]);
    } catch (e) {
      throw FieldParseException(
        key: key,
        innerException: e,
      );
    }
  }
}

extension JsonArray on List {
  E convert<E>() {
    final t = _typeOf<E>();
    if (_factories.containsKey(t)) {
      return _factories[t](this) as E;
    }

    return [] as E;
  }
}

Type _typeOf<T>() => T;
typedef JsonFactory<E> = E Function(dynamic value);

final _defaultValues = <Type, dynamic>{};

final _factories = <Type, dynamic>{
  _typeOf<List<String>>(): (data) {
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }

    return [];
  },
  _typeOf<List<String>?>(): (data) {
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }

    return [];
  },
};

final _toJsonFactories = <Type, dynamic Function(dynamic value)>{};

final _converters = <Type, dynamic>{};
void registerJsonConverter<E>(JsonConverter<E> converter) {
  _converters[E] = converter;
  _converters[_typeOf<E?>()] = converter;
}

void registerDefaultValue(Map<Type, dynamic> values) {
  _defaultValues.addAll(values);
}

void registerJsonFactory<E>(JsonFactory<E> builder) {
  _factories[E] = builder;
  _factories[_typeOf<E?>()] = builder;
  _factories[_typeOf<List<E>>()] =
      (List list) => list.map((e) => builder(e)).toList();
  _factories[_typeOf<List<E>?>()] =
      (List list) => list.map((e) => builder(e)).toList();
  _factories[_typeOf<FutureOr<List<E>>>()] =
      (List list) => list.map((e) => builder(e)).toList();
}

void registerToJson<E>(dynamic Function(dynamic value) toJson) {
  _toJsonFactories[E] = toJson;
}

T modelDecode<T>(dynamic data) {
  if (data is List) {
    return data.convert<T>();
  }

  if (_factories.containsKey(T)) {
    return _factories[T](data);
  }

  throw UnsupportedError('unsupported type');
}

E convertFromJson<E>(
  dynamic value, [
  dynamic defaultValue,
  bool useConverters = true,
]) {
  if (E == dynamic) {
    return value;
  }

  if (value == null) {
    if (defaultValue != null) return defaultValue;
    return null as E;
  }

  if (value is Map && (value).isEmpty) {
    if (defaultValue != null) return defaultValue;
    return null as E;
  }

  if (useConverters) {
    if (_converters.containsKey(E)) {
      final converter = _converters[E] as JsonConverter<E>;
      return converter.fromJson(value);
    }
  }

  if (_factories.containsKey(E)) {
    return _factories[E](value);
  }

  if (_factories.containsKey(_typeOf<E>())) {
    return _factories[_typeOf<E>()](value);
  }

  if (E == String || E == _typeOf<String>() || E == _typeOf<String?>()) {
    if (value == null) {
      if (E == _typeOf<String?>()) {
        return null as E;
      }

      return 0 as E;
    }

    return value.toString() as E;
  }

  if (E == int || E == _typeOf<int>() || E == _typeOf<int?>()) {
    if (value == null) {
      if (E == _typeOf<int?>()) {
        return null as E;
      }

      return 0 as E;
    }

    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }

    if (value is num) {
      return value.toInt() as E;
    }

    return defaultValue as E;
  }

  if (E == double || E == _typeOf<double>() || E == _typeOf<double?>()) {
    if (value == null) {
      if (E == _typeOf<double?>()) {
        return null as E;
      }

      return 0.0 as E;
    }

    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }

    if (value is num) {
      return value.toDouble() as E;
    }

    return defaultValue as E;
  }

  if (E == num || E == _typeOf<num>() || E == _typeOf<num?>()) {
    if (value == null) {
      if (E == _typeOf<num?>()) {
        return null as E;
      }

      return 0.0 as E;
    }

    if (value is String) {
      return num.tryParse(value) ?? defaultValue;
    }

    if (value is num) {
      return value as E;
    }

    return defaultValue as E;
  }

  if (E == DateTime || E == _typeOf<DateTime>() || E == _typeOf<DateTime?>()) {
    if (value == null) {
      if (E == _typeOf<DateTime?>()) {
        return null as E;
      }

      return 0 as E;
    }

    if (value is String) {
      var str = value;
      if (str.length > 10 && !str.contains('Z') && !str.contains('+')) {
        str += 'Z';
      }

      return DateTime.parse(str).toLocal() as E;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value) as E;
    }

    if (value is DateTime) {
      return value as E;
    }

    return DateTime.fromMillisecondsSinceEpoch(0) as E;
  }

  if (E == bool || E == _typeOf<bool>() || E == _typeOf<bool?>()) {
    if (value is bool) {
      return value as E;
    }

    if (value is String) {
      return (value == '1' || value == 'true') as E;
    }

    if (value is int) {
      return (value == 1) as E;
    }

    return false as E;
  }

  if (E == List || E == _typeOf<List>() || E == _typeOf<List?>()) {
    return (value as List).convert();
  }

  if (value is List) {
    return (value).convert();
  }

  if (value is Map<String, dynamic>) {
    return (value).convert();
  }

  return value;
}

dynamic convertToJson(
  dynamic value, [
  bool useConverter = true,
  dynamic Function(dynamic object)? toJson,
]) {
  if (useConverter) {
    if (_converters.containsKey(value.runtimeType)) {
      final converter = _converters[value.runtimeType] as JsonConverter;
      return converter.toJson(value);
    }
  }

  if (_toJsonFactories.containsKey(value.runtimeType)) {
    final toJson = _toJsonFactories[value.runtimeType]!;
    return toJson(value);
  }

  if (value is List) {
    return value.map((e) => convertToJson(e)).toList();
  }

  if (value is Map) {
    return value.map((key, value) => MapEntry(key, convertToJson(value)));
  }

  if (value is DateTime) {
    return value.toUtc().toIso8601String();
  }

  return value;
}
