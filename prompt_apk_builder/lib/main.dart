import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_apk_builder/app/bootstrap.dart';
import 'package:prompt_apk_builder/app/router/app_router.dart';
import 'package:prompt_apk_builder/app/theme/app_theme.dart';

void main() async {
  await bootstrap(() async => const PromptApkBuilderApp());
}

class PromptApkBuilderApp extends ConsumerWidget {
  const PromptApkBuilderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Prompt → APK (K1W1 Builder)',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        // Add localization delegates here when implementing German translations
      ],
    );
  }
}
