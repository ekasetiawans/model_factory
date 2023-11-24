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
      return json.toLowerCase() == 'true';
    }

    throw 'Cannot parse "$json" as bool.';
  }

  @override
  dynamic toJson(bool? object) => object;
}

class DateTimeJsonAdapter extends JsonAdapter<DateTime?> {
  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;

    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json, isUtc: true);
    } else if (json is DateTime) {
      return json;
    } else if (json is String) {
      var str = json;
      if (str.length > 10 && !str.contains('Z') && !str.contains('+')) {
        str += 'Z';
      }

      return DateTime.parse(str).toLocal();
    }

    throw 'Cannot parse "$json" as DateTime.';
  }

  @override
  dynamic toJson(DateTime? object) => object?.toIso8601String();
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

void registerDefaultAdapters() {
  GetIt.I.registerSingleton<JsonAdapter<int?>>(IntJsonAdapter());
  GetIt.I.registerSingleton<JsonAdapter<List<int>?>>(ListJsonAdapter<int>());
  GetIt.I.registerSingleton<JsonAdapter<double?>>(DoubleJsonAdapter());
  GetIt.I
      .registerSingleton<JsonAdapter<List<double>?>>(ListJsonAdapter<double>());
  GetIt.I.registerSingleton<JsonAdapter<String?>>(StringJsonAdapter());
  GetIt.I
      .registerSingleton<JsonAdapter<List<String>?>>(ListJsonAdapter<String>());
  GetIt.I.registerSingleton<JsonAdapter<bool?>>(BoolJsonAdapter());
  GetIt.I.registerSingleton<JsonAdapter<List<bool>?>>(ListJsonAdapter<bool>());
  GetIt.I.registerSingleton<JsonAdapter<DateTime?>>(DateTimeJsonAdapter());
  GetIt.I.registerSingleton<JsonAdapter<List<DateTime>?>>(
      ListJsonAdapter<DateTime>());
}
