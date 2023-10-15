// ignore_for_file: type=lint

// This file is autogenerated by model_factory
// DO NOT MODIFY BY HAND
// To re-generate this file, run:
//    flutter pub run build_runner build

part of 'my_model.dart';

// **************************************************************************
// Generator: ModelFactoryBuilder
// **************************************************************************

typedef MyModelJsonDeserializer = MyModel Function(Map<String, dynamic> json);
final MyModelJsonDeserializer defaultMyModelDeserializer = (
  Map<String, dynamic> json,
) {
  try {
    return MyModel(
      name: json.valueOf<String>(
        MyModelMetadata.instance.name,
      ),
    );
  } on FieldParseException catch (e) {
    throw ModelParseException(
      innerException: e.innerException,
      key: e.key,
      className: 'MyModel',
    );
  }
};
MyModel _$MyModelFromJson(Map<String, dynamic> json) =>
    defaultMyModelDeserializer(json);

typedef MyModelJsonSerializer = Map<String, dynamic> Function(MyModel instance);
final MyModelJsonSerializer defaultMyModelSerializer = (MyModel instance) {
  return {
    MyModelMetadata.instance.name: convertToJson(instance.name),
  };
};

Map<String, dynamic> _$MyModelToJson(MyModel instance) =>
    defaultMyModelSerializer(instance);

extension MyModelJsonExtension on MyModel {
  Map<String, dynamic> toJson() => _$MyModelToJson(this);
  MyModel copyWith({
    String? name,
  }) =>
      MyModel(
        name: name ?? this.name,
      );

  void apply(MyModel other) {}

  MyModel clone() => _$MyModelFromJson(toJson());

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
