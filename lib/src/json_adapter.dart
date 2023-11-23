import 'package:get_it/get_it.dart';

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

dynamic tryDecode<E>(dynamic json) {
  if (json is List) {
    return json.map((e) => tryDecode<E>(e)).toList().cast<E>();
  }

  if (GetIt.I.isRegistered<JsonAdapter<E?>>()) {
    return GetIt.I<JsonAdapter<E?>>().fromJson(json);
  }

  throw JsonAdapterNotRegisteredException(E);
}

dynamic tryEncode<E>(E? object) {
  if (object is List) {
    return object.map((e) => tryEncode<E>(e)).toList();
  }

  if (GetIt.I.isRegistered<JsonAdapter<E?>>()) {
    return GetIt.I<JsonAdapter<E?>>().toJson(object);
  }

  throw JsonAdapterNotRegisteredException(E);
}
