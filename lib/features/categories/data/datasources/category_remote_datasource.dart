import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_exception.dart';
import '../models/category.dart';

/// Remote data source for meal categories (TheMealDB `categories.php`).
class CategoryRemoteDataSource {
  const CategoryRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Category>> fetchCategories() async {
    try {
      final Response<dynamic> response =
          await _dio.get<dynamic>(ApiConfig.categories);
      final Object? data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ApiException('Unexpected response format.');
      }
      final Object? rawList = data['categories'];
      if (rawList is! List) {
        return const <Category>[];
      }
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(Category.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
