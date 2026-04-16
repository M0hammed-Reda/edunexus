import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../viewmodel/auth_viewmodel.dart';

/// Login / Role-selection screen.
/// The user taps one of two cards to enter the app as Teacher or Student.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),

              // ── App Logo ────────────────────────────────────────────────
              const Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: Color(0xFF3D5AF1),
                  child: Icon(Icons.school, size: 48, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),

              // ── App Name ────────────────────────────────────────────────
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF3D5AF1)),
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 56),

              // ── Role Selection Heading ───────────────────────────────────
              Text(
                'I am a...',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),

              // ── Teacher Card ─────────────────────────────────────────────
              _RoleCard(
                icon: Icons.person_pin,
                label: 'Teacher',
                description: 'Post announcements, upload materials & create assignments',
                color: const Color(0xFF3D5AF1),
                onTap: () => ref.read(authProvider.notifier).loginAsTeacher(),
              ),
              const SizedBox(height: 16),

              // ── Student Card ─────────────────────────────────────────────
              _RoleCard(
                icon: Icons.menu_book,
                label: 'Student',
                description: 'View announcements, materials & submit assignments',
                color: const Color(0xFF2EC4B6),
                onTap: () => ref.read(authProvider.notifier).loginAsStudent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable Role Card widget ─────────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withAlpha(26),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
