class StateModel {
  final String id;
  final String name;
  final String code;
  final String? image;

  StateModel({
    required this.id,
    required this.name,
    required this.code,
    this.image,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'image': image,
    };
  }
}
