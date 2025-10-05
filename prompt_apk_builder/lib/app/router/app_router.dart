import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_apk_builder/features/onboarding/onboarding_screen.dart';
import 'package:prompt_apk_builder/features/home/home_screen.dart';
import 'package:prompt_apk_builder/features/builder/builder_screen.dart';
import 'package:prompt_apk_builder/features/status/status_screen.dart';
import 'package:prompt_apk_builder/features/settings/settings_screen.dart';
import 'package:prompt_apk_builder/features/history/history_screen.dart';

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String builder = '/builder';
  static const String status = '/status';
  static const String settings = '/settings';
  static const String history = '/history';

  static GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: builder,
        builder: (context, state) => const BuilderScreen(),
      ),
      GoRoute(
        path: status,
        builder: (context, state) => const StatusScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: history,
        builder: (context, state) => const HistoryScreen(),
      ),
    ],
  );
}