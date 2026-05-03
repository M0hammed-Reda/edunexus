/// Represents a row in the `announcements` table.
class AnnouncementModel {
  final String id;
  final String classroomId;
  final String title;
  final String content;
  final String createdBy; // FK → users.id
  final DateTime createdAt;

  const AnnouncementModel({
    required this.id,
    required this.classroomId,
    required this.title,
    required this.content,
    required this.createdBy,
    required this.createdAt,
  });

  // ─── FACTORY PATTERN ────────────────────────────────────────────
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      AnnouncementModel(
        id: json['id'] as String,
        classroomId: json['classroom_id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        createdBy: json['created_by'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'classroom_id': classroomId,
        'title': title,
        'content': content,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
      };
}
