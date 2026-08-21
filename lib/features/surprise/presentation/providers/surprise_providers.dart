import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../meals/data/models/meal.dart';
import '../../../meals/data/repositories/meal_repository.dart';
import '../../../meals/presentation/providers/meal_providers.dart';

/// Fetches a fresh random meal each time it is invalidated.
///
/// The "Surprise Me" page invalidates this provider to spin the roulette and
/// land on a new random recipe.
final FutureProvider<Meal?> randomMealProvider =
    FutureProvider<Meal?>((Ref ref) async {
  final MealRepository repo = ref.watch(mealRepositoryProvider);
  return repo.randomMeal();
});
