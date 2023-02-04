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
    if (containsKey(key) && this[key] is String) {
      return this[key];
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
    }

    return defaultValue;
  }

  DateTime? dateTime(String key) {
    if (containsKey(key) && this[key] is String) {
      String str = this[key];
      if (str.length > 10 && !str.contains('Z') && !str.contains('+')) {
        str += 'Z';
      }

      return DateTime.parse(str).toLocal();
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

T modelDecode<T>(dynamic data) {
  if (data is List) {
    return data.convert<T>();
  }

  if (_factories.containsKey(T)) {
    return _factories[T](data);
  }

  throw UnsupportedError('unsupported type');
}
