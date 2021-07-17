class ModelLain {
  final String name;
  ModelLain({required this.name});

  factory ModelLain.fromJson(Map<String, dynamic> json) =>
      ModelLain(name: json['name']);
}

class ModelYangLain {
  final String name;
  ModelYangLain({required this.name});

  factory ModelYangLain.fromJson(Map<String, dynamic> json) =>
      ModelYangLain(name: json['name']);
}
