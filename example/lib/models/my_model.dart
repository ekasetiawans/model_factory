class MyModel {
  final String name;
  MyModel({required this.name});

  factory MyModel.fromJson(Map<String, dynamic> json) =>
      MyModel(name: json['name']);
}
