import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/view/login_screen.dart';
import '../../features/auth/view/signup_screen.dart';
import '../../features/auth/viewmodel/auth_viewmodel.dart';
import '../../features/assignments/view/assignment_list_screen.dart';
import '../../features/assignments/view/create_assignment_screen.dart';
import '../../features/home/view/classroom_list_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/submissions/view/submission_screen.dart';

/// Provides a GoRouter instance that reacts to auth state changes.
/// When authProvider changes, the router re-evaluates redirect logic.
final routerProvider = Provider<GoRouter>((ref) {
  // Listening to auth state so the router rebuilds on login/logout
  final authState = ref.watch(authProvider);
  final user = authState.user;

  return GoRouter(
    initialLocation: '/login',
    // ── Redirect logic ──────────────────────────────────────────────────────
    redirect: (context, state) {
      final isLoggedIn = user != null;
      final isLoginRoute = state.matchedLocation == '/login';
      final isSignupRoute = state.matchedLocation == '/signup';

      // Not logged in and not on login or signup page → send to login
      if (!isLoggedIn && !isLoginRoute && !isSignupRoute) return '/login';
      // Already logged in and trying to access auth pages → send to classrooms
      if (isLoggedIn && (isLoginRoute || isSignupRoute)) return '/classrooms';
      return null; // no redirect needed
    },
    // ── Routes ──────────────────────────────────────────────────────────────
    routes: [
      GoRoute(
        path: '/login',
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (ctx, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/classrooms',
        builder: (ctx, state) => const ClassroomListScreen(),
      ),
      GoRoute(
        path: '/home/:classroomId',
        builder: (ctx, state) {
          return HomeScreen(classroomId: state.pathParameters['classroomId']!);
        },
      ),
      GoRoute(
        path: '/assignments',
        builder: (ctx, state) => const AssignmentListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (ctx, state) => const CreateAssignmentScreen(),
          ),
          GoRoute(
            path: ':id/submit',
            builder: (ctx, state) {
              final assignmentId = state.pathParameters['id']!;
              return SubmissionScreen(assignmentId: assignmentId);
            },
          ),
        ],
      ),
    ],
  );
});
