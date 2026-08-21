import '../../meals/data/models/ingredient.dart';
import '../../meals/data/models/meal.dart';
import 'shopping_item.dart';

/// Pure domain logic that turns a set of favorited [Meal]s into a de-duplicated
/// shopping list.
///
/// Rules:
/// * Ingredients are grouped case-insensitively by trimmed name.
/// * Distinct, non-empty measures are preserved (so "200g" + "1 cup" both show).
/// * Duplicate measures for the same ingredient are collapsed.
/// * The number of favorited meals using each ingredient is counted.
/// * Output is sorted alphabetically for a stable, scannable list.
///
/// This is intentionally free of Flutter/Riverpod so it is trivially unit
/// testable.
class ShoppingListBuilder {
  const ShoppingListBuilder();

  List<ShoppingItem> build(List<Meal> favorites) {
    // Preserve display name (first-seen) while grouping by normalized key.
    final Map<String, String> displayNames = <String, String>{};
    final Map<String, List<String>> measuresByKey = <String, List<String>>{};
    final Map<String, int> mealCountByKey = <String, int>{};

    for (final Meal meal in favorites) {
      // A single meal should count once per distinct ingredient even if it
      // (rarely) repeats an ingredient name internally.
      final Set<String> seenInThisMeal = <String>{};

      for (final Ingredient ingredient in meal.ingredients) {
        final String key = ingredient.normalizedName;
        if (key.isEmpty) continue;

        displayNames.putIfAbsent(key, () => _titleCase(ingredient.name));

        final List<String> measures =
            measuresByKey.putIfAbsent(key, () => <String>[]);
        final String measure = ingredient.measure.trim();
        if (measure.isNotEmpty && !measures.contains(measure)) {
          measures.add(measure);
        }

        if (seenInThisMeal.add(key)) {
          mealCountByKey[key] = (mealCountByKey[key] ?? 0) + 1;
        }
      }
    }

    final List<ShoppingItem> items = displayNames.keys.map((String key) {
      return ShoppingItem(
        name: displayNames[key]!,
        measures: measuresByKey[key] ?? const <String>[],
        mealCount: mealCountByKey[key] ?? 0,
      );
    }).toList();

    items.sort(
      (ShoppingItem a, ShoppingItem b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return items;
  }

  String _titleCase(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }
}
