import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'teaching/learning_screen.dart';
import 'teaching/quiz_screen.dart';

void main() {
  runApp(const ProviderScope(child: VietBrailleApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/learn',
      builder: (context, state) => const LearningScreen(),
    ),
    GoRoute(path: '/quiz', builder: (context, state) => const QuizScreen()),
  ],
);

class VietBrailleApp extends ConsumerWidget {
  const VietBrailleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final fontScale = ref.watch(fontScaleProvider);

    return MaterialApp.router(
      title: 'Vietnamese Braille',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.light(fontScale: fontScale),
      darkTheme: AppTheme.dark(fontScale: fontScale),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
