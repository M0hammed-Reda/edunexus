/// Represents a row in the `users` table.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'teacher' or 'student'
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  // ─── FACTORY PATTERN ────────────────────────────────────────────
  // Constructs a UserModel from a JSON map (e.g., API response).
  // Centralises parsing logic so callers never touch raw maps.
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'created_at': createdAt.toIso8601String(),
      };

  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';
}
