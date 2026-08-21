import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/theme/theme_provider.dart';
import 'features/favorites/data/favorites_repository.dart';
import 'features/favorites/presentation/providers/favorites_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local persistence before the first frame so favorites and the
  // theme preference are available synchronously to providers.
  await Hive.initFlutter();
  final Box<String> favoritesBox =
      await Hive.openBox<String>(FavoritesRepository.boxName);
  final Box<dynamic> settingsBox =
      await Hive.openBox<dynamic>(ThemeModeNotifier.boxName);

  runApp(
    ProviderScope(
      overrides: <Override>[
        favoritesBoxProvider.overrideWithValue(favoritesBox),
        settingsBoxProvider.overrideWithValue(settingsBox),
      ],
      child: const MealMateApp(),
    ),
  );
}
