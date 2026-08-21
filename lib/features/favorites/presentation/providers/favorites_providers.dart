import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../meals/data/models/meal.dart';
import '../../data/favorites_repository.dart';

/// The favorites Hive box, opened at bootstrap and provided via override.
final Provider<Box<String>> favoritesBoxProvider = Provider<Box<String>>(
  (Ref ref) =>
      throw UnimplementedError('favoritesBoxProvider must be overridden'),
);

final Provider<FavoritesRepository> favoritesRepositoryProvider =
    Provider<FavoritesRepository>(
  (Ref ref) => FavoritesRepository(ref.watch(favoritesBoxProvider)),
);

/// Holds the list of favorited meals and keeps the UI in sync with Hive.
class FavoritesNotifier extends StateNotifier<List<Meal>> {
  FavoritesNotifier(this._repository) : super(_repository.getAll());

  final FavoritesRepository _repository;

  bool isFavorite(String mealId) => state.any((Meal meal) => meal.id == mealId);

  Future<bool> toggle(Meal meal) async {
    final bool nowFavorite = await _repository.toggle(meal);
    state = _repository.getAll();
    return nowFavorite;
  }

  Future<void> remove(String mealId) async {
    await _repository.remove(mealId);
    state = _repository.getAll();
  }
}

final StateNotifierProvider<FavoritesNotifier, List<Meal>> favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Meal>>(
  (Ref ref) => FavoritesNotifier(ref.watch(favoritesRepositoryProvider)),
);

/// Convenience: whether a specific meal id is currently favorited.
final ProviderFamily<bool, String> isFavoriteProvider =
    Provider.family<bool, String>((Ref ref, String mealId) {
  final List<Meal> favorites = ref.watch(favoritesProvider);
  return favorites.any((Meal meal) => meal.id == mealId);
});
