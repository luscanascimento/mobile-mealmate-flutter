import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/providers.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/models/category.dart';
import '../../data/repositories/category_repository.dart';

final Provider<CategoryRepository> categoryRepositoryProvider =
    Provider<CategoryRepository>((Ref ref) {
  final CategoryRemoteDataSource remote =
      CategoryRemoteDataSource(ref.watch(dioProvider));
  return CategoryRepository(remote);
});

/// Loads and caches the list of meal categories.
final FutureProvider<List<Category>> categoriesProvider =
    FutureProvider<List<Category>>((Ref ref) async {
  final CategoryRepository repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories();
});
