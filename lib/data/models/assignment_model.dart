/// Represents a row in the `assignments` table.
class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final String createdBy; // FK → users.id
  final DateTime createdAt;

  const AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.createdBy,
    required this.createdAt,
  });

  // ─── FACTORY PATTERN ────────────────────────────────────────────
  factory AssignmentModel.fromJson(Map<String, dynamic> json) =>
      AssignmentModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        deadline: DateTime.parse(json['deadline'] as String),
        createdBy: json['created_by'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
      };

  bool get isOverdue => DateTime.now().isAfter(deadline);
}
