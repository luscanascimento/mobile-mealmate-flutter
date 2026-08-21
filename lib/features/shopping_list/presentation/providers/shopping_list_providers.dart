import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../../meals/data/models/meal.dart';
import '../../domain/shopping_item.dart';
import '../../domain/shopping_list_builder.dart';

final Provider<ShoppingListBuilder> shoppingListBuilderProvider =
    Provider<ShoppingListBuilder>((Ref ref) => const ShoppingListBuilder());

/// Derived, auto-updating shopping list aggregated from all favorites.
///
/// Because it `watch`es [favoritesProvider], adding or removing a favorite
/// instantly recomputes the list — no manual refresh needed.
final Provider<List<ShoppingItem>> shoppingListProvider =
    Provider<List<ShoppingItem>>((Ref ref) {
  final List<Meal> favorites = ref.watch(favoritesProvider);
  final ShoppingListBuilder builder = ref.watch(shoppingListBuilderProvider);
  return builder.build(favorites);
});
