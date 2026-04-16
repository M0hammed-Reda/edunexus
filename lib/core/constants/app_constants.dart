/// App-wide constants — avoids magic strings scattered through the codebase.
class AppConstants {
  AppConstants._(); // Private constructor: this class is never instantiated

  static const String appName = 'EduNexus';
  static const String appTagline = 'SWE2 Educational Platform';

  // User roles — must match the "role" column in the users table
  static const String teacherRole = 'teacher';
  static const String studentRole = 'student';

  // Mock user IDs (simulating UUIDs from the DB)
  static const String teacherUserId = '11111111-1111-1111-1111-111111111111';
  static const String studentUserId = '22222222-2222-2222-2222-222222222222';
}
