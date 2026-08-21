import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../meals/data/models/meal.dart';
import '../../../meals/data/repositories/meal_repository.dart';
import '../../../meals/presentation/providers/meal_providers.dart';

/// Current search query text. Updated by the search field.
final StateProvider<String> searchQueryProvider =
    StateProvider<String>((Ref ref) => '');

/// Search results for the current query.
///
/// Returns an empty list for blank/too-short queries so we don't spam the API
/// on every keystroke. The UI additionally debounces input.
final FutureProvider<List<Meal>> searchResultsProvider =
    FutureProvider<List<Meal>>((Ref ref) async {
  final String query = ref.watch(searchQueryProvider).trim();
  if (query.length < 2) {
    return const <Meal>[];
  }
  final MealRepository repo = ref.watch(mealRepositoryProvider);
  return repo.search(query);
});
