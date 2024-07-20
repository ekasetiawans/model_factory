// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_model.dart';

// **************************************************************************
// Generator: ModelFactoryBuilder
// **************************************************************************

class MyModelJsonAdapter extends JsonAdapter<MyModel?> {
  static void register() {
    GetIt.I.registerSingleton<JsonAdapter<MyModel?>>(MyModelJsonAdapter());
    GetIt.I.registerFactoryParam<MyModel, dynamic, dynamic>(
        (json, _) => GetIt.I<JsonAdapter<MyModel?>>().fromJson(json)!);
  }

  @pragma('vm:entry-point')
  @override
  MyModel? fromJson(dynamic json) {
    if (json == null) return null;
    try {
      return MyModel(
        name: decode<String>(
          json,
          MyModelMetadata.instance.name,
          isNullable: false,
        )!,
        dinamic: decode<dynamic>(
          json,
          MyModelMetadata.instance.dinamic,
          isNullable: false,
        )!,
      );
    } on FieldParseException catch (e) {
      throw ModelParseException(
        innerException: e.innerException,
        key: e.key,
        className: 'MyModel',
      );
    }
  }

  @pragma('vm:entry-point')
  @override
  dynamic toJson(MyModel? instance) {
    if (instance == null) return null;
    return {
      MyModelMetadata.instance.name:
          encode<String>(instance.name, MyModelMetadata.instance.name)!,
      MyModelMetadata.instance.dinamic:
          encode<dynamic>(instance.dinamic, MyModelMetadata.instance.dinamic)!,
    };
  }

  MyModelMetadata get metadata => MyModelMetadata.instance;
  List<JsonField> get allFields => metadata.allJsonFields;
}

_$MyModelFromJson(dynamic json) =>
    GetIt.I<JsonAdapter<MyModel?>>().fromJson(json)!;

extension MyModelJsonExtension on MyModel {
  @pragma('vm:entry-point')
  dynamic toJson() => GetIt.I<JsonAdapter<MyModel?>>().toJson(this);
  void setValue(String field, dynamic value) {
    switch (field) {}
  }

  dynamic getValue(String field) {
    switch (field) {
      case 'name':
        return name;
      case 'dynamic':
        return dinamic;
    }
    return null;
  }

  MyModel copyWith({
    String? name,
    dynamic dinamic,
  }) =>
      MyModel(
        name: name ?? this.name,
        dinamic: dinamic ?? this.dinamic,
      );

  void apply(MyModel other) {}

  MyModel clone() => GetIt.I<JsonAdapter<MyModel?>>().fromJson(toJson()!)!;

  MyModelMetadata get metadata => MyModelMetadata.instance;
}

class MyModelMetadata {
  static final MyModelMetadata instance = MyModelMetadata._();
  MyModelMetadata._();
  final String name = 'name';
  final String dinamic = 'dynamic';

  List<String> get fields => [
        'name',
        'dynamic',
      ];
  List<String> get allFields => [
        'name',
        'dynamic',
      ];
  Map<String, String> get aliases => {};
  List<JsonField> get allJsonFields => [
        JsonField<MyModel>(
          name: 'name',
          field: 'name',
          alias: null,
          fieldType: String,
          fromSuper: false,
          handler: (instance) => instance.name,
        ),
        JsonField<MyModel>(
          name: 'dinamic',
          field: 'dynamic',
          alias: null,
          fieldType: dynamic,
          fromSuper: false,
          handler: (instance) => instance.dinamic,
        ),
      ];
  dynamic valueOf(MyModel instance, String fieldName) {
    switch (fieldName) {
      case 'name':
        return instance.name;
      case 'dynamic':
        return instance.dinamic;
      default:
        return null;
    }
  }
}

class ModelWithoutConstructorJsonAdapter
    extends JsonAdapter<ModelWithoutConstructor?> {
  static void register() {
    GetIt.I.registerSingleton<JsonAdapter<ModelWithoutConstructor?>>(
        ModelWithoutConstructorJsonAdapter());
    GetIt.I.registerFactoryParam<ModelWithoutConstructor, dynamic, dynamic>(
        (json, _) =>
            GetIt.I<JsonAdapter<ModelWithoutConstructor?>>().fromJson(json)!);
  }

  @pragma('vm:entry-point')
  @override
  ModelWithoutConstructor? fromJson(dynamic json) {
    if (json == null) return null;
    try {
      return ModelWithoutConstructor();
    } on FieldParseException catch (e) {
      throw ModelParseException(
        innerException: e.innerException,
        key: e.key,
        className: 'ModelWithoutConstructor',
      );
    }
  }

  @pragma('vm:entry-point')
  @override
  dynamic toJson(ModelWithoutConstructor? instance) {
    if (instance == null) return null;
    return {};
  }

  ModelWithoutConstructorMetadata get metadata =>
      ModelWithoutConstructorMetadata.instance;
  List<JsonField> get allFields => metadata.allJsonFields;
}

_$ModelWithoutConstructorFromJson(dynamic json) =>
    GetIt.I<JsonAdapter<ModelWithoutConstructor?>>().fromJson(json)!;

extension ModelWithoutConstructorJsonExtension on ModelWithoutConstructor {
  @pragma('vm:entry-point')
  dynamic toJson() =>
      GetIt.I<JsonAdapter<ModelWithoutConstructor?>>().toJson(this);
  void setValue(String field, dynamic value) {
    switch (field) {}
  }

  dynamic getValue(String field) {
    switch (field) {}
    return null;
  }

  void apply(ModelWithoutConstructor other) {}

  ModelWithoutConstructor clone() =>
      GetIt.I<JsonAdapter<ModelWithoutConstructor?>>().fromJson(toJson()!)!;

  ModelWithoutConstructorMetadata get metadata =>
      ModelWithoutConstructorMetadata.instance;
}

class ModelWithoutConstructorMetadata {
  static final ModelWithoutConstructorMetadata instance =
      ModelWithoutConstructorMetadata._();
  ModelWithoutConstructorMetadata._();

  List<String> get fields => [];
  List<String> get allFields => [];
  Map<String, String> get aliases => {};
  List<JsonField> get allJsonFields => [];
  dynamic valueOf(ModelWithoutConstructor instance, String fieldName) {
    switch (fieldName) {
      default:
        return null;
    }
  }
}
