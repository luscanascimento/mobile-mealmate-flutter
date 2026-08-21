/// Central place for API endpoints.
///
/// MealMate uses TheMealDB free/public test endpoint, which requires no API
/// key. Everything is served over HTTPS. There are deliberately **no secrets**
/// in this file — if a production key were ever introduced it would be injected
/// via `--dart-define` at build time, never committed to source control.
class ApiConfig {
  const ApiConfig._();

  /// HTTPS-only base URL. The `v1/1` test key is the documented public key
  /// published by TheMealDB and is not a secret.
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints.
  static const String categories = '/categories.php';
  static const String filterByCategory = '/filter.php';
  static const String searchByName = '/search.php';
  static const String lookupById = '/lookup.php';
  static const String randomMeal = '/random.php';
}
