import '../datasources/category_remote_datasource.dart';
import '../models/category.dart';

/// Repository that exposes category data to the presentation layer.
///
/// Kept intentionally thin here, but this is the seam where caching or a local
/// fallback would live.
class CategoryRepository {
  const CategoryRepository(this._remote);

  final CategoryRemoteDataSource _remote;

  Future<List<Category>> getCategories() => _remote.fetchCategories();
}
