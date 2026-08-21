import 'package:equatable/equatable.dart';

/// A single, de-duplicated line in the aggregated shopping list.
///
/// [measures] holds every distinct measure seen for this ingredient across all
/// favorited meals (e.g. "200g", "1 cup"), and [mealCount] how many favorites
/// use it — useful context for the shopper.
class ShoppingItem extends Equatable {
  const ShoppingItem({
    required this.name,
    required this.measures,
    required this.mealCount,
  });

  final String name;
  final List<String> measures;
  final int mealCount;

  /// Human-readable measures joined for display, or an empty string when the
  /// source data provided none.
  String get measuresLabel => measures.join(' + ');

  bool get hasMeasures => measures.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[name, measures, mealCount];
}
