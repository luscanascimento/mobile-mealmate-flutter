import '../datasources/meal_remote_datasource.dart';
import '../models/meal.dart';
import '../models/meal_summary.dart';

/// Repository exposing meal operations to the presentation layer.
class MealRepository {
  const MealRepository(this._remote);

  final MealRemoteDataSource _remote;

  Future<List<MealSummary>> mealsByCategory(String category) =>
      _remote.mealsByCategory(category);

  Future<List<Meal>> search(String query) => _remote.searchByName(query.trim());

  Future<Meal?> mealById(String id) => _remote.mealById(id);

  Future<Meal?> randomMeal() => _remote.randomMeal();
}
