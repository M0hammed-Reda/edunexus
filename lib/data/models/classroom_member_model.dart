class ClassroomMemberModel {
  final String id;
  final String classroomId;
  final String userId;
  final String status;
  final DateTime joinedAt;
  final Map<String, dynamic>? user; // Optional user details

  const ClassroomMemberModel({
    required this.id,
    required this.classroomId,
    required this.userId,
    required this.status,
    required this.joinedAt,
    this.user,
  });

  factory ClassroomMemberModel.fromJson(Map<String, dynamic> json) => ClassroomMemberModel(
        id: json['id'] as String,
        classroomId: json['classroom_id'] as String,
        userId: json['user_id'] as String,
        status: json['status'] as String,
        joinedAt: DateTime.parse(json['joined_at'] as String),
        user: json['user'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'classroom_id': classroomId,
        'user_id': userId,
        'status': status,
        'joined_at': joinedAt.toIso8601String(),
        if (user != null) 'user': user,
      };

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
}
