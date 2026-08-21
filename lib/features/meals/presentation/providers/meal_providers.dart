import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/providers.dart';
import '../../data/datasources/meal_remote_datasource.dart';
import '../../data/models/meal.dart';
import '../../data/models/meal_summary.dart';
import '../../data/repositories/meal_repository.dart';

final Provider<MealRepository> mealRepositoryProvider =
    Provider<MealRepository>((Ref ref) {
  final MealRemoteDataSource remote =
      MealRemoteDataSource(ref.watch(dioProvider));
  return MealRepository(remote);
});

/// Meals for a given category id/name (used by the category detail page).
final FutureProviderFamily<List<MealSummary>, String> mealsByCategoryProvider =
    FutureProvider.family<List<MealSummary>, String>(
        (Ref ref, String category) async {
  final MealRepository repo = ref.watch(mealRepositoryProvider);
  return repo.mealsByCategory(category);
});

/// Full meal detail by id.
final FutureProviderFamily<Meal?, String> mealDetailProvider =
    FutureProvider.family<Meal?, String>((Ref ref, String id) async {
  final MealRepository repo = ref.watch(mealRepositoryProvider);
  return repo.mealById(id);
});
