import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';

/// ─── OBSERVER PATTERN (Riverpod) ────────────────────────────────────────────
/// AuthNotifier holds the currently logged-in user (or null).
/// Any widget that watches [authProvider] is automatically notified when
/// the user logs in or out — this IS the Observer pattern.
/// ────────────────────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null); // Initial state: no user logged in

  void loginAsTeacher() {
    state = UserModel(
      id: AppConstants.teacherUserId,
      name: 'Dr. Ahmed Hassan',
      email: 'teacher@edunexus.com',
      role: AppConstants.teacherRole,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  void loginAsStudent() {
    state = UserModel(
      id: AppConstants.studentUserId,
      name: 'Sara Mohamed',
      email: 'student@edunexus.com',
      role: AppConstants.studentRole,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  void logout() => state = null;
}

/// The provider — exposes AuthNotifier to the widget tree.
/// This is the Observable that widgets Subscribe to.
final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>(
  (ref) => AuthNotifier(),
);
