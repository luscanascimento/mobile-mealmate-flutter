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

/// Ticked-off items, keyed by `ShoppingItem.key`.
///
/// Held here rather than in the tile's `State` because the list reorders and
/// shrinks as favorites change: element recycling in `ListView` would otherwise
/// leave a checkmark on whichever ingredient inherited the row.
final StateProvider<Set<String>> checkedItemsProvider =
    StateProvider<Set<String>>((Ref ref) => <String>{});
