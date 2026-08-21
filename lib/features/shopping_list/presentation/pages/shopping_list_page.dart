import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/state_views.dart';
import '../../domain/shopping_item.dart';
import '../providers/shopping_list_providers.dart';

/// An auto-generated, de-duplicated shopping list aggregated
/// from every favorited meal. Updates live as favorites change.
class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ShoppingItem> items = ref.watch(shoppingListProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
      body: items.isEmpty
          ? const EmptyStateView(
              title: 'Your list is empty',
              message:
                  'Favorite some recipes and their ingredients will be merged here automatically.',
              icon: Icons.shopping_cart_outlined,
            )
          : Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  color: theme.colorScheme.primaryContainer,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    '${items.length} unique ingredient${items.length == 1 ? '' : 's'} '
                    'across your favorites',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) =>
                        _ShoppingTile(item: items[index]),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ShoppingTile extends StatefulWidget {
  const _ShoppingTile({required this.item});
  final ShoppingItem item;

  @override
  State<_ShoppingTile> createState() => _ShoppingTileState();
}

class _ShoppingTileState extends State<_ShoppingTile> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ShoppingItem item = widget.item;

    return CheckboxListTile(
      value: _checked,
      onChanged: (bool? value) =>
          setState(() => _checked = value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        item.name,
        style: theme.textTheme.titleMedium?.copyWith(
          decoration: _checked ? TextDecoration.lineThrough : null,
          color: _checked ? theme.colorScheme.outline : null,
        ),
      ),
      subtitle: item.hasMeasures
          ? Text(item.measuresLabel)
          : const Text('Quantity not specified'),
      secondary: item.mealCount > 1
          ? Chip(
              visualDensity: VisualDensity.compact,
              label: Text('x${item.mealCount}'),
            )
          : null,
    );
  }
}
