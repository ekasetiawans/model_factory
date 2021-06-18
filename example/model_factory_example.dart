import 'package:model_factory/model_factory.dart';

void main() {
  registerJsonFactory((json) => MyModel.fromJson(json));
}

class MyModel {
  final String name;
  MyModel({required this.name});

  factory MyModel.fromJson(Map<String, dynamic> json) =>
      MyModel(name: json['name']);
}
