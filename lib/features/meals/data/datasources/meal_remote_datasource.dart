import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_exception.dart';
import '../models/meal.dart';
import '../models/meal_summary.dart';

/// Remote data source for meals (browse, search, detail, random).
class MealRemoteDataSource {
  const MealRemoteDataSource(this._dio);

  final Dio _dio;

  /// Browse meals belonging to a [category] (`filter.php?c=`).
  Future<List<MealSummary>> mealsByCategory(String category) async {
    return _summaryList(
      ApiConfig.filterByCategory,
      <String, dynamic>{'c': category},
    );
  }

  /// Search meals by [query] (`search.php?s=`). Returns full meals.
  Future<List<Meal>> searchByName(String query) async {
    return _mealList(
      ApiConfig.searchByName,
      <String, dynamic>{'s': query},
    );
  }

  /// Look up a single meal by [id] (`lookup.php?i=`).
  Future<Meal?> mealById(String id) async {
    final List<Meal> meals = await _mealList(
      ApiConfig.lookupById,
      <String, dynamic>{'i': id},
    );
    return meals.isEmpty ? null : meals.first;
  }

  /// Fetch a single random meal (`random.php`).
  Future<Meal?> randomMeal() async {
    final List<Meal> meals = await _mealList(ApiConfig.randomMeal, null);
    return meals.isEmpty ? null : meals.first;
  }

  Future<List<MealSummary>> _summaryList(
    String path,
    Map<String, dynamic>? query,
  ) async {
    final List<Map<String, dynamic>> raw = await _rawMeals(path, query);
    return raw.map(MealSummary.fromJson).toList(growable: false);
  }

  Future<List<Meal>> _mealList(
    String path,
    Map<String, dynamic>? query,
  ) async {
    final List<Map<String, dynamic>> raw = await _rawMeals(path, query);
    return raw.map(Meal.fromApiJson).toList(growable: false);
  }

  /// Shared, defensive extraction of the `meals` array.
  ///
  /// TheMealDB returns `{"meals": null}` when there are no results, so we treat
  /// a null/absent list as an empty result rather than an error.
  Future<List<Map<String, dynamic>>> _rawMeals(
    String path,
    Map<String, dynamic>? query,
  ) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        path,
        queryParameters: query,
      );
      final Object? data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ApiException('Unexpected response format.');
      }
      final Object? meals = data['meals'];
      if (meals is! List) {
        return const <Map<String, dynamic>>[];
      }
      return meals.whereType<Map<String, dynamic>>().toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
