import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_summary.freezed.dart';
part 'meal_summary.g.dart';

/// Lightweight meal representation used in lists/grids.
///
/// Returned by `filter.php` (category browsing) which only provides id, name
/// and thumbnail.
@freezed
class MealSummary with _$MealSummary {
  const factory MealSummary({
    @JsonKey(name: 'idMeal') required String id,
    @JsonKey(name: 'strMeal') required String name,
    @JsonKey(name: 'strMealThumb') String? thumbnail,
  }) = _MealSummary;

  factory MealSummary.fromJson(Map<String, dynamic> json) =>
      _$MealSummaryFromJson(json);
}
