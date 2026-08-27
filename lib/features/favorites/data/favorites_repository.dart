import 'dart:convert';

import 'package:hive/hive.dart';

import '../../meals/data/models/meal.dart';

/// Persists favorited meals locally using a Hive box.
///
/// We store the full [Meal] (as JSON) rather than just its id, so the favorites
/// list and the aggregated shopping list work with no network.
class FavoritesRepository {
  FavoritesRepository(this._box);

  static const String boxName = 'favorites';

  final Box<String> _box;

  List<Meal> getAll() {
    final List<Meal> meals = <Meal>[];
    for (final String key in _box.keys.cast<String>()) {
      final String? raw = _box.get(key);
      if (raw == null) continue;
      try {
        final Map<String, dynamic> json =
            Map<String, dynamic>.from(jsonDecode(raw) as Map);
        meals.add(Meal.fromJson(json));
      } catch (_) {
        // Skip any corrupt entry rather than crashing the whole list.
      }
    }
    // Stable, predictable ordering by name.
    meals.sort(
      (Meal a, Meal b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return meals;
  }

  bool isFavorite(String mealId) => _box.containsKey(mealId);

  Future<void> add(Meal meal) async {
    await _box.put(meal.id, jsonEncode(meal.toJson()));
  }

  Future<void> remove(String mealId) async {
    await _box.delete(mealId);
  }

  /// Returns the new favorite state after toggling.
  Future<bool> toggle(Meal meal) async {
    if (isFavorite(meal.id)) {
      await remove(meal.id);
      return false;
    }
    await add(meal);
    return true;
  }
}
