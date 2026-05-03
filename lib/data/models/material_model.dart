/// Represents a row in the `materials` table.
class MaterialModel {
  final String id;
  final String classroomId;
  final String title;
  final String fileUrl; // URL to the uploaded file (or file name in mock)
  final String uploadedBy; // FK → users.id
  final DateTime createdAt;

  const MaterialModel({
    required this.id,
    required this.classroomId,
    required this.title,
    required this.fileUrl,
    required this.uploadedBy,
    required this.createdAt,
  });

  // ─── FACTORY PATTERN ────────────────────────────────────────────
  factory MaterialModel.fromJson(Map<String, dynamic> json) => MaterialModel(
        id: json['id'] as String,
        classroomId: json['classroom_id'] as String,
        title: json['title'] as String,
        fileUrl: json['file_url'] as String,
        uploadedBy: json['uploaded_by'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'classroom_id': classroomId,
        'title': title,
        'file_url': fileUrl,
        'uploaded_by': uploadedBy,
        'created_at': createdAt.toIso8601String(),
      };
}
