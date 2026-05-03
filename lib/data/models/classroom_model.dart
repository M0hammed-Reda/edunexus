class ClassroomModel {
  final String id;
  final String name;
  final String uniqueCode;
  final String managerId;
  final DateTime createdAt;

  const ClassroomModel({
    required this.id,
    required this.name,
    required this.uniqueCode,
    required this.managerId,
    required this.createdAt,
  });

  factory ClassroomModel.fromJson(Map<String, dynamic> json) => ClassroomModel(
        id: json['id'] as String,
        name: json['name'] as String,
        uniqueCode: json['unique_code'] as String,
        managerId: json['manager_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unique_code': uniqueCode,
        'manager_id': managerId,
        'created_at': createdAt.toIso8601String(),
      };
}
