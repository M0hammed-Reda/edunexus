import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  // ProviderScope is the root of the Observer pattern — all providers live here.
  runApp(const ProviderScope(child: EduNexusApp()));
}

class EduNexusApp extends ConsumerWidget {
  const EduNexusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching routerProvider re-builds when auth state changes,
    // triggering go_router's redirect automatically.
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'EduNexus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
