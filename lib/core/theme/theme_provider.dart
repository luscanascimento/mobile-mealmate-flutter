import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Persists and exposes the user's preferred [ThemeMode].
///
/// The preference is stored in a small Hive settings box so the chosen theme
/// survives app restarts.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._box) : super(_read(_box));

  static const String boxName = 'settings';
  static const String _key = 'theme_mode';

  final Box<dynamic> _box;

  static ThemeMode _read(Box<dynamic> box) {
    final String? raw = box.get(_key) as String?;
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> toggle() async {
    final ThemeMode next =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await set(next);
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _box.put(_key, mode.name);
  }
}

/// The settings box is opened during bootstrap and provided via override.
final Provider<Box<dynamic>> settingsBoxProvider = Provider<Box<dynamic>>(
  (Ref ref) =>
      throw UnimplementedError('settingsBoxProvider must be overridden'),
);

final StateNotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (Ref ref) => ThemeModeNotifier(ref.watch(settingsBoxProvider)),
);
