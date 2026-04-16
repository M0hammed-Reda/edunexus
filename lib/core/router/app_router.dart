import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/view/login_screen.dart';
import '../../features/auth/viewmodel/auth_viewmodel.dart';
import '../../features/assignments/view/assignment_list_screen.dart';
import '../../features/assignments/view/create_assignment_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/submissions/view/submission_screen.dart';

/// Provides a GoRouter instance that reacts to auth state changes.
/// When authProvider changes, the router re-evaluates redirect logic.
final routerProvider = Provider<GoRouter>((ref) {
  // Listening to auth state so the router rebuilds on login/logout
  final user = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    // ── Redirect logic ──────────────────────────────────────────────────────
    redirect: (context, state) {
      final isLoggedIn = user != null;
      final isLoginRoute = state.matchedLocation == '/login';

      // Not logged in and not on login page → send to login
      if (!isLoggedIn && !isLoginRoute) return '/login';
      // Already logged in and on login page → send to home
      if (isLoggedIn && isLoginRoute) return '/home';
      return null; // no redirect needed
    },
    // ── Routes ──────────────────────────────────────────────────────────────
    routes: [
      GoRoute(
        path: '/login',
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (ctx, state) => const HomeScreen(),
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
