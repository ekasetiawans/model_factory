// GENERATED CODE - DO NOT MODIFY BY HAND

part of 't_model.dart';

// **************************************************************************
// Generator: ModelFactoryBuilder
// **************************************************************************

class ParentJsonAdapter implements JsonAdapter<Parent?> {
  @override
  Parent? fromJson(dynamic json) {
    if (json == null) return null;
    try {
      return Parent(
        id: tryDecode<int>(json[ParentMetadata.instance.id])!,
        name: tryDecode<String>(json[ParentMetadata.instance.name])!,
        address: tryDecode<String>(json[ParentMetadata.instance.address]),
      );
    } on FieldParseException catch (e) {
      throw ModelParseException(
        innerException: e.innerException,
        key: e.key,
        className: 'Parent',
      );
    }
  }

  @override
  dynamic toJson(Parent? instance) {
    if (instance == null) return null;
    return {
      ParentMetadata.instance.id: tryEncode<int>(instance.id)!,
      ParentMetadata.instance.name: tryEncode<String>(instance.name)!,
      ParentMetadata.instance.address: tryEncode<String>(instance.address),
    };
  }
}

_$ParentFromJson(dynamic json) =>
    GetIt.I<JsonAdapter<Parent?>>().fromJson(json)!;

extension ParentJsonExtension on Parent {
  dynamic toJson() => GetIt.I<JsonAdapter<Parent?>>().toJson(this);
  Parent copyWith({
    int? id,
    String? name,
    String? address,
  }) =>
      Parent(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
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

  List<String> get fields => [
        'id',
        'name',
        'address',
      ];
  List<String> get allFields => [
        'id',
        'name',
        'address',
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
      ];
  dynamic valueOf(Parent instance, String fieldName) {
    switch (fieldName) {
      case 'id':
        return instance.id;
      case 'name':
        return instance.name;
      case 'address':
        return instance.address;
      default:
        return null;
    }
  }
}

class KidJsonAdapter implements JsonAdapter<Kid?> {
  @override
  Kid? fromJson(dynamic json) {
    if (json == null) return null;
    try {
      return Kid(
        id: tryDecode<int>(json[KidMetadata.instance.id])!,
        name: tryDecode<String>(json[KidMetadata.instance.name])!,
        father: tryDecode<Parent>(json[KidMetadata.instance.father])!,
        mother: tryDecode<Parent>(json[KidMetadata.instance.mother]),
        born: tryDecode<DateTime>(json[KidMetadata.instance.born])!,
      );
    } on FieldParseException catch (e) {
      throw ModelParseException(
        innerException: e.innerException,
        key: e.key,
        className: 'Kid',
      );
    }
  }

  @override
  dynamic toJson(Kid? instance) {
    if (instance == null) return null;
    return {
      KidMetadata.instance.id: tryEncode<int>(instance.id)!,
      KidMetadata.instance.name: tryEncode<String>(instance.name)!,
      KidMetadata.instance.father: tryEncode<Parent>(instance.father)!,
      KidMetadata.instance.mother: tryEncode<Parent>(instance.mother),
      KidMetadata.instance.born: tryEncode<DateTime>(instance.born)!,
    };
  }
}

_$KidFromJson(dynamic json) => GetIt.I<JsonAdapter<Kid?>>().fromJson(json)!;

extension KidJsonExtension on Kid {
  dynamic toJson() => GetIt.I<JsonAdapter<Kid?>>().toJson(this);
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
