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
        name: decode<String>(json, MyModelMetadata.instance.name)!,
      );
    } on FieldParseException catch (e) {
      throw ModelParseException(
        innerException: e.innerException,
        key: e.key,
        className: 'MyModel',
      );
    } catch (e) {
      throw ModelParseException(
        innerException: e,
        key: '',
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
    };
  }
}

_$MyModelFromJson(dynamic json) =>
    GetIt.I<JsonAdapter<MyModel?>>().fromJson(json)!;

extension MyModelJsonExtension on MyModel {
  @pragma('vm:entry-point')
  dynamic toJson() => GetIt.I<JsonAdapter<MyModel?>>().toJson(this);
  MyModel copyWith({
    String? name,
  }) =>
      MyModel(
        name: name ?? this.name,
      );

  void apply(MyModel other) {}

  MyModel clone() => GetIt.I<JsonAdapter<MyModel?>>().fromJson(toJson()!)!;

  MyModelMetadata get metadata => MyModelMetadata.instance;
}

class MyModelMetadata {
  static final MyModelMetadata instance = MyModelMetadata._();
  MyModelMetadata._();
  final String name = 'name';

  List<String> get fields => [
        'name',
      ];
  List<String> get allFields => [
        'name',
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
      ];
  dynamic valueOf(MyModel instance, String fieldName) {
    switch (fieldName) {
      case 'name':
        return instance.name;
      default:
        return null;
    }
  }
}
