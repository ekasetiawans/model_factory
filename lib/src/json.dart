import 'dart:async';
import 'dart:convert';

class JsonKey {
  final String name;
  const JsonKey({this.name = ''});
}

class JsonSerializable {
  const JsonSerializable();
}

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
    if (!containsKey(key)) {
      return null as E;
    }

    if (_factories.containsKey(E)) {
      return _factories[E](this[key]);
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

    if (E == _typeOf<List<String>>()) {
      return (this[key] as List).map((e) => e.toString()).toList() as E;
    }

    if (E == _typeOf<List<String?>>()) {
      return (this[key] as List).map((e) => e?.toString()).toList() as E;
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

    if (this[key] == null && defaultValue != null) {
      return defaultValue;
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
typedef JsonFactory<E> = E Function(Map<String, dynamic> value);

final _factories = <Type, dynamic>{};
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
