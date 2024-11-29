import 'package:model_factory/model_factory.dart';

class IntJsonAdapter extends JsonAdapter<int?> {
  @override
  int? fromJson(dynamic json) {
    if (json == null) return null;

    if (json is num) {
      return json.toInt();
    } else if (json is int) {
      return json;
    } else if (json is String) {
      if (json.trim().isEmpty) {
        return null;
      }

      return int.parse(json);
    }

    throw 'Cannot parse "$json" as int.';
  }

  @override
  dynamic toJson(int? object) => object;
}

class DoubleJsonAdapter extends JsonAdapter<double?> {
  @override
  double? fromJson(dynamic json) {
    if (json == null) return null;

    if (json is num) {
      return json.toDouble();
    } else if (json is double) {
      return json;
    } else if (json is String) {
      if (json.trim().isEmpty) {
        return null;
      }
      return double.parse(json);
    }

    throw 'Cannot parse "$json" as double.';
  }

  @override
  dynamic toJson(double? object) => object;
}

class StringJsonAdapter extends JsonAdapter<String?> {
  @override
  String? fromJson(dynamic json) {
    if (json == null) return null;

    if (json is String) {
      return json;
    } else {
      return json.toString();
    }
  }

  @override
  dynamic toJson(String? object) => object;
}

class BoolJsonAdapter extends JsonAdapter<bool?> {
  @override
  bool? fromJson(dynamic json) {
    if (json == null) return null;

    if (json is int) {
      return json == 1;
    } else if (json is bool) {
      return json;
    } else if (json is String) {
      if (json.trim().isEmpty) {
        return false;
      }

      return json.toLowerCase() == 'true';
    }

    throw 'Cannot parse "$json" as bool.';
  }

  @override
  dynamic toJson(bool? object) => object;
}

class DateTimeJsonAdapter extends JsonAdapter<DateTime?> {
  bool deserializeToLocalTimezone = true;
  bool serializeToUTC = true;

  static DateTimeJsonAdapter get instance =>
      GetIt.I<JsonAdapter<DateTime?>>() as DateTimeJsonAdapter;

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;

    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json, isUtc: true);
    } else if (json is DateTime) {
      return json;
    } else if (json is String) {
      var str = json;
      if (str.trim().isEmpty) {
        return null;
      }

      if (str.length > 10 && !str.contains('Z') && !str.contains('+')) {
        str += 'Z';
      }

      if (!deserializeToLocalTimezone) {
        return DateTime.parse(str);
      }

      return DateTime.parse(str).toLocal();
    }

    throw 'Cannot parse "$json" as DateTime.';
  }

  @override
  dynamic toJson(DateTime? object) {
    if (!serializeToUTC) {
      return object?.toIso8601String();
    }

    return object?.toUtc().toIso8601String();
  }
}

class ListJsonAdapter<T> extends JsonAdapter<List<T>?> {
  late final JsonAdapter<T?> itemAdapter;

  ListJsonAdapter() {
    itemAdapter = GetIt.I<JsonAdapter<T?>>();
  }

  @override
  List<T>? fromJson(dynamic json) {
    if (json == null) return null;

    if (json is List) {
      return json.map((e) => itemAdapter.fromJson(e)!).toList();
    }

    throw 'Cannot parse "$json" as List<$T>.';
  }

  @override
  dynamic toJson(List<T>? object) => object?.map((e) => itemAdapter.toJson(e));
}

class MapJsonAdapter extends JsonAdapter<Map<String, dynamic>?> {
  MapJsonAdapter();

  @override
  Map<String, dynamic>? fromJson(dynamic json) {
    if (json == null) return null;

    if (json is Map) {
      return json.cast();
    }

    throw 'Cannot parse "$json" as Map<Sting, dynamic>';
  }

  @override
  dynamic toJson(Map<String, dynamic>? object) => object;
}

void _registerIfNotRegisterd<T>(JsonAdapter<T> adapter) {
  if (!GetIt.I.isRegistered<JsonAdapter<T>>()) {
    GetIt.I.registerSingleton<JsonAdapter<T>>(adapter);
  }
}

void _registerDefaultAdapters() {
  _registerIfNotRegisterd(IntJsonAdapter());
  _registerIfNotRegisterd(DoubleJsonAdapter());
  _registerIfNotRegisterd(StringJsonAdapter());
  _registerIfNotRegisterd(BoolJsonAdapter());
  _registerIfNotRegisterd(DateTimeJsonAdapter());
  _registerIfNotRegisterd(ListJsonAdapter<int>());
  _registerIfNotRegisterd(ListJsonAdapter<double>());
  _registerIfNotRegisterd(ListJsonAdapter<String>());
  _registerIfNotRegisterd(ListJsonAdapter<bool>());
  _registerIfNotRegisterd(ListJsonAdapter<DateTime>());
  _registerIfNotRegisterd(MapJsonAdapter());
}

abstract class JsonRegistrant {
  void registerAdapters() {
    _registerDefaultAdapters();
  }
}
