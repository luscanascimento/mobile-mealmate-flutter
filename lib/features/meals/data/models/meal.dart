import 'package:freezed_annotation/freezed_annotation.dart';

import 'ingredient.dart';
import 'meal_summary.dart';

part 'meal.freezed.dart';
part 'meal.g.dart';

/// Full meal detail as returned by `lookup.php` / `random.php` / `search.php`.
///
/// Two JSON shapes exist and are deliberately given separate names:
///
/// * [Meal.fromApiJson] parses TheMealDB's wire format, where ingredients are
///   20 flat fields (`strIngredient1..20` / `strMeasure1..20`). It is
///   defensive: unexpected or missing keys never throw.
/// * [Meal.fromJson] / `toJson` are the generated, canonical form used to
///   persist favorites in Hive.
@freezed
class Meal with _$Meal {
  const Meal._();

  // explicitToJson so nested Ingredients are serialized to plain maps: without
  // it `toJson()` leaks Ingredient instances and `Meal.fromJson(m.toJson())`
  // throws (it only survives a trip through jsonEncode).
  @JsonSerializable(explicitToJson: true)
  const factory Meal({
    required String id,
    required String name,
    String? category,
    String? area,
    String? instructions,
    String? thumbnail,
    String? youtubeUrl,
    String? sourceUrl,
    @Default(<String>[]) List<String> tags,
    @Default(<Ingredient>[]) List<Ingredient> ingredients,
  }) = _Meal;

  /// Canonical form used for local (Hive) persistence of favorites.
  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);

  /// Parses TheMealDB's wire format, folding the flat ingredient pairs.
  factory Meal.fromApiJson(Map<String, dynamic> json) {
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
}
