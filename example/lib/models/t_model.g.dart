// GENERATED CODE - DO NOT MODIFY BY HAND

part of 't_model.dart';

// **************************************************************************
// Generator: ModelFactoryBuilder
// **************************************************************************

class ParentJsonAdapter extends JsonAdapter<Parent?> {
  static void register() {
    GetIt.I.registerSingleton<JsonAdapter<Parent?>>(ParentJsonAdapter());
    GetIt.I.registerFactoryParam<Parent, dynamic, dynamic>(
        (json, _) => GetIt.I<JsonAdapter<Parent?>>().fromJson(json)!);
  }

  @pragma('vm:entry-point')
  @override
  Parent? fromJson(dynamic json) {
    if (json == null) return null;
    try {
      return Parent(
        id: decode<int>(
          json,
          ParentMetadata.instance.id,
          isNullable: false,
        )!,
        name: decode<String>(
          json,
          ParentMetadata.instance.name,
          isNullable: false,
          defaultValue: 'John Doe',
        )!,
        address: decode<String>(
          json,
          ParentMetadata.instance.address,
          isNullable: true,
        ),
        hobbies: decode<String>(
          json,
          ParentMetadata.instance.hobbies,
          isList: true,
          isNullable: true,
        ),
      );
    } on FieldParseException catch (e) {
      throw ModelParseException(
        innerException: e.innerException,
        key: e.key,
        className: 'Parent',
      );
    }
  }

  @pragma('vm:entry-point')
  @override
  dynamic toJson(Parent? instance) {
    if (instance == null) return null;
    return {
      ParentMetadata.instance.id:
          encode<int>(instance.id, ParentMetadata.instance.id)!,
      ParentMetadata.instance.name:
          encode<String>(instance.name, ParentMetadata.instance.name)!,
      if (instance.address != null)
        ParentMetadata.instance.address:
            encode<String>(instance.address, ParentMetadata.instance.address),
      if (instance.hobbies != null)
        ParentMetadata.instance.hobbies:
            encode<String>(instance.hobbies, ParentMetadata.instance.hobbies),
    };
  }

  ParentMetadata get metadata => ParentMetadata.instance;
  @override
  List<JsonField> get allFields => metadata.allJsonFields;
}

Parent _$ParentFromJson(dynamic json) =>
    GetIt.I<JsonAdapter<Parent?>>().fromJson(json)!;

extension ParentJsonExtension on Parent {
  @pragma('vm:entry-point')
  dynamic toJson() => GetIt.I<JsonAdapter<Parent?>>().toJson(this);
  void setValue(String field, dynamic value) {
    switch (field) {}
  }

  dynamic getValue(String field) {
    switch (field) {
      case 'id':
        return id;
      case 'name':
        return name;
      case 'address':
        return address;
      case 'hobbies':
        return hobbies;
    }
    return null;
  }

  Parent copyWith({
    int? id,
    String? name,
    String? address,
    List<String>? hobbies,
  }) =>
      Parent(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
        hobbies: hobbies ?? this.hobbies,
      );

  void apply(Parent other) {}

  Parent clone() => GetIt.I<JsonAdapter<Parent?>>().fromJson(toJson()!)!;

  ParentMetadata get metadata => ParentMetadata.instance;
}

class ParentMetadata {
  static final ParentMetadata instance = ParentMetadata._();
  ParentMetadata._();
  final String id = 'id';
  final String name = 'name';
  final String address = 'address';
  final String hobbies = 'hobbies';

  List<String> get fields => [
        'id',
        'name',
        'address',
        'hobbies',
      ];
  List<String> get allFields => [
        'id',
        'name',
        'address',
        'hobbies',
      ];
  Map<String, String> get aliases => {};
  List<JsonField> get allJsonFields => [
        JsonField<Parent>(
          name: 'id',
          field: 'id',
          alias: null,
          fieldType: int,
          fromSuper: false,
          handler: (instance) => instance.id,
        ),
        JsonField<Parent>(
          name: 'name',
          field: 'name',
          alias: null,
          fieldType: String,
          fromSuper: false,
          handler: (instance) => instance.name,
        ),
        JsonField<Parent>(
          name: 'address',
          field: 'address',
          alias: null,
          fieldType: String,
          fromSuper: false,
          handler: (instance) => instance.address,
        ),
        JsonField<Parent>(
          name: 'hobbies',
          field: 'hobbies',
          alias: null,
          fieldType: List<String>,
          fromSuper: false,
          handler: (instance) => instance.hobbies,
        ),
      ];
  dynamic valueOf(Parent instance, String fieldName) {
    switch (fieldName) {
      case 'id':
        return instance.id;
      case 'name':
        return instance.name;
      case 'address':
        return instance.address;
      case 'hobbies':
        return instance.hobbies;
      default:
        return null;
    }
  }
}

class KidJsonAdapter extends JsonAdapter<Kid?> {
  static void register() {
    GetIt.I.registerSingleton<JsonAdapter<Kid?>>(KidJsonAdapter());
    GetIt.I.registerFactoryParam<Kid, dynamic, dynamic>(
        (json, _) => GetIt.I<JsonAdapter<Kid?>>().fromJson(json)!);
  }

  @pragma('vm:entry-point')
  @override
  Kid? fromJson(dynamic json) {
    if (json == null) return null;
    try {
      return Kid(
        id: decode<int>(
          json,
          KidMetadata.instance.id,
          isNullable: false,
        )!,
        name: decode<String>(
          json,
          KidMetadata.instance.name,
          isNullable: false,
        )!,
        father: decode<Parent>(
          json,
          KidMetadata.instance.father,
          isNullable: false,
        )!,
        mother: decode<Parent>(
          json,
          KidMetadata.instance.mother,
          isNullable: true,
        ),
        born: decode<DateTime>(
          json,
          KidMetadata.instance.born,
          isNullable: false,
        )!,
      );
    } on FieldParseException catch (e) {
      throw ModelParseException(
        innerException: e.innerException,
        key: e.key,
        className: 'Kid',
      );
    }
  }

  @pragma('vm:entry-point')
  @override
  dynamic toJson(Kid? instance) {
    if (instance == null) return null;
    return {
      KidMetadata.instance.id:
          encode<int>(instance.id, KidMetadata.instance.id)!,
      KidMetadata.instance.name:
          encode<String>(instance.name, KidMetadata.instance.name)!,
      KidMetadata.instance.father:
          encode<Parent>(instance.father, KidMetadata.instance.father)!,
      if (instance.mother != null)
        KidMetadata.instance.mother:
            encode<Parent>(instance.mother, KidMetadata.instance.mother),
      KidMetadata.instance.born:
          encode<DateTime>(instance.born, KidMetadata.instance.born)!,
    };
  }

  KidMetadata get metadata => KidMetadata.instance;
  @override
  List<JsonField> get allFields => metadata.allJsonFields;
}

Kid _$KidFromJson(dynamic json) => GetIt.I<JsonAdapter<Kid?>>().fromJson(json)!;

extension KidJsonExtension on Kid {
  @pragma('vm:entry-point')
  dynamic toJson() => GetIt.I<JsonAdapter<Kid?>>().toJson(this);
  void setValue(String field, dynamic value) {
    switch (field) {}
  }

  dynamic getValue(String field) {
    switch (field) {
      case 'id':
        return id;
      case 'name':
        return name;
      case 'father':
        return father;
      case 'mother':
        return mother;
      case 'born_on':
        return born;
    }
    return null;
  }

  Kid copyWith({
    int? id,
    String? name,
    Parent? father,
    Parent? mother,
    DateTime? born,
  }) =>
      Kid(
        id: id ?? this.id,
        name: name ?? this.name,
        father: father ?? this.father,
        mother: mother ?? this.mother,
        born: born ?? this.born,
      );

  void apply(Kid other) {}

  Kid clone() => GetIt.I<JsonAdapter<Kid?>>().fromJson(toJson()!)!;

  KidMetadata get metadata => KidMetadata.instance;
}

class KidMetadata {
  static final KidMetadata instance = KidMetadata._();
  KidMetadata._();
  final String id = 'id';
  final String name = 'name';
  final String father = 'father';
  final String mother = 'mother';
  final String born = 'born_on';

  List<String> get fields => [
        'id',
        'name',
        'father',
        'mother',
        'born_on',
      ];
  List<String> get allFields => [
        'id',
        'name',
        'father',
        'mother',
        'born_on',
      ];
  Map<String, String> get aliases => {};
  List<JsonField> get allJsonFields => [
        JsonField<Kid>(
          name: 'id',
          field: 'id',
          alias: null,
          fieldType: int,
          fromSuper: false,
          handler: (instance) => instance.id,
        ),
        JsonField<Kid>(
          name: 'name',
          field: 'name',
          alias: null,
          fieldType: String,
          fromSuper: false,
          handler: (instance) => instance.name,
        ),
        JsonField<Kid>(
          name: 'father',
          field: 'father',
          alias: null,
          fieldType: Parent,
          fromSuper: false,
          handler: (instance) => instance.father,
        ),
        JsonField<Kid>(
          name: 'mother',
          field: 'mother',
          alias: null,
          fieldType: Parent,
          fromSuper: false,
          handler: (instance) => instance.mother,
        ),
        JsonField<Kid>(
          name: 'born',
          field: 'born_on',
          alias: null,
          fieldType: DateTime,
          fromSuper: false,
          handler: (instance) => instance.born,
        ),
      ];
  dynamic valueOf(Kid instance, String fieldName) {
    switch (fieldName) {
      case 'id':
        return instance.id;
      case 'name':
        return instance.name;
      case 'father':
        return instance.father;
      case 'mother':
        return instance.mother;
      case 'born_on':
        return instance.born;
      default:
        return null;
    }
  }
}
