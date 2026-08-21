import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

/// Root widget. Wires up the theme, router and Material 3 configuration.
class MealMateApp extends ConsumerStatefulWidget {
  const MealMateApp({super.key});

  @override
  ConsumerState<MealMateApp> createState() => _MealMateAppState();
}

class _MealMateAppState extends ConsumerState<MealMateApp> {
  late final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'MealMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
