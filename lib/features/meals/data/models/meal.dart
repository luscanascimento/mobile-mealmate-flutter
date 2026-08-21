import 'package:equatable/equatable.dart';

import 'ingredient.dart';
import 'meal_summary.dart';

/// Full meal detail as returned by `lookup.php` / `random.php` / `search.php`.
///
/// TheMealDB returns ingredients and measures as 20 flat fields
/// (`strIngredient1..20`, `strMeasure1..20`). We fold those into a clean list
/// of [Ingredient]s here, skipping empty/whitespace-only pairs. All parsing is
/// defensive: unexpected/missing keys never throw.
class Meal extends Equatable {
  const Meal({
    required this.id,
    required this.name,
    this.category,
    this.area,
    this.instructions,
    this.thumbnail,
    this.youtubeUrl,
    this.sourceUrl,
    this.tags = const <String>[],
    this.ingredients = const <Ingredient>[],
  });

  final String id;
  final String name;
  final String? category;
  final String? area;
  final String? instructions;
  final String? thumbnail;
  final String? youtubeUrl;
  final String? sourceUrl;
  final List<String> tags;
  final List<Ingredient> ingredients;

  MealSummary toSummary() =>
      MealSummary(id: id, name: name, thumbnail: thumbnail);

  /// Instruction lines split into readable steps.
  ///
  /// TheMealDB stores instructions as one blob separated by newlines (or, in a
  /// few records, by `\r\n`). We split, trim, and drop blanks.
  List<String> get steps {
    final String? raw = instructions;
    if (raw == null || raw.trim().isEmpty) return const <String>[];
    return raw
        .split(RegExp(r'\r?\n'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
  }

  bool get hasYoutube {
    final String? url = youtubeUrl;
    return url != null &&
        url.trim().isNotEmpty &&
        Uri.tryParse(url)?.isScheme('https') == true;
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    String? str(String key) {
      final Object? value = json[key];
      if (value == null) return null;
      final String s = value.toString().trim();
      return s.isEmpty ? null : s;
    }

    // Fold the 20 flat ingredient/measure pairs.
    final List<Ingredient> parsed = <Ingredient>[];
    for (int i = 1; i <= 20; i++) {
      final String? name = str('strIngredient$i');
      if (name == null) continue;
      final String measure = str('strMeasure$i') ?? '';
      parsed.add(Ingredient(name: name, measure: measure));
    }

    final String? rawTags = str('strTags');
    final List<String> tags = rawTags == null
        ? const <String>[]
        : rawTags
            .split(',')
            .map((String t) => t.trim())
            .where((String t) => t.isNotEmpty)
            .toList(growable: false);

    return Meal(
      id: str('idMeal') ?? '',
      name: str('strMeal') ?? 'Unknown meal',
      category: str('strCategory'),
      area: str('strArea'),
      instructions: str('strInstructions'),
      thumbnail: str('strMealThumb'),
      youtubeUrl: str('strYoutube'),
      sourceUrl: str('strSource'),
      tags: tags,
      ingredients: parsed,
    );
  }

  /// Serialization for local (Hive) persistence of favorites.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'category': category,
        'area': area,
        'instructions': instructions,
        'thumbnail': thumbnail,
        'youtubeUrl': youtubeUrl,
        'sourceUrl': sourceUrl,
        'tags': tags,
        'ingredients':
            ingredients.map((Ingredient e) => e.toJson()).toList(),
      };

  factory Meal.fromStoredJson(Map<String, dynamic> json) {
    final List<dynamic> rawIngredients =
        (json['ingredients'] as List<dynamic>?) ?? const <dynamic>[];
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      area: json['area'] as String?,
      instructions: json['instructions'] as String?,
      thumbnail: json['thumbnail'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((dynamic e) => e as String)
              .toList() ??
          const <String>[],
      ingredients: rawIngredients
          .map((dynamic e) =>
              Ingredient.fromJson(Map<String, dynamic>.from(e as Map)),)
          .toList(),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        category,
        area,
        instructions,
        thumbnail,
        youtubeUrl,
        sourceUrl,
        tags,
        ingredients,
      ];
}
