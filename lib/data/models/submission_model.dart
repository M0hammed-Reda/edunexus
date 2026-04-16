/// Represents a row in the `submissions` table.
class SubmissionModel {
  final String id;
  final String assignmentId; // FK → assignments.id
  final String studentId;    // FK → users.id
  final String fileUrl;      // URL/path of submitted file
  final DateTime submittedAt;
  final double? grade;       // Nullable — null means not yet graded
  final DateTime createdAt;

  const SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.fileUrl,
    required this.submittedAt,
    this.grade,
    required this.createdAt,
  });

  // ─── FACTORY PATTERN ────────────────────────────────────────────
  factory SubmissionModel.fromJson(Map<String, dynamic> json) =>
      SubmissionModel(
        id: json['id'] as String,
        assignmentId: json['assignment_id'] as String,
        studentId: json['student_id'] as String,
        fileUrl: json['file_url'] as String,
        submittedAt: DateTime.parse(json['submitted_at'] as String),
        grade: json['grade'] != null ? (json['grade'] as num).toDouble() : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'assignment_id': assignmentId,
        'student_id': studentId,
        'file_url': fileUrl,
        'submitted_at': submittedAt.toIso8601String(),
        'grade': grade,
        'created_at': createdAt.toIso8601String(),
      };
}
