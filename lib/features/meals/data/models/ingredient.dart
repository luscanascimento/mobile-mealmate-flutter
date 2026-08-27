import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient.freezed.dart';
part 'ingredient.g.dart';

/// A single recipe ingredient paired with its measure (e.g. "Flour" / "200g").
///
/// Fields default to `''` rather than being required so a partially corrupt
/// persisted entry degrades to a blank field instead of dropping the meal.
@freezed
class Ingredient with _$Ingredient {
  const Ingredient._();

  const factory Ingredient({
    @Default('') String name,
    @Default('') String measure,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);

  /// Normalized key used for de-duplication in the shopping list
  /// (case-insensitive, trimmed).
  String get normalizedName => name.trim().toLowerCase();
}
