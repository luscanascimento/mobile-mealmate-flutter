import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealmate/features/shopping_list/domain/shopping_item.dart';
import 'package:mealmate/features/shopping_list/presentation/pages/shopping_list_page.dart';
import 'package:mealmate/features/shopping_list/presentation/providers/shopping_list_providers.dart';

/// Stand-in for the favorites-derived list so the test can reorder/shrink it.
final StateProvider<List<ShoppingItem>> _items =
    StateProvider<List<ShoppingItem>>((Ref ref) => const <ShoppingItem>[]);

ShoppingItem _item(String name) =>
    ShoppingItem(name: name, measures: const <String>['1'], mealCount: 1);

/// Reads the rendered checkbox state of the row titled [name].
bool _checked(WidgetTester tester, String name) {
  final CheckboxListTile tile = tester.widget<CheckboxListTile>(
    find.ancestor(
      of: find.text(name),
      matching: find.byType(CheckboxListTile),
    ),
  );
  return tile.value ?? false;
}

Future<ProviderContainer> _pumpPage(
  WidgetTester tester,
  List<ShoppingItem> initial,
) async {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      _items.overrideWith((Ref ref) => initial),
      shoppingListProvider.overrideWith((Ref ref) => ref.watch(_items)),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ShoppingListPage()),
    ),
  );
  return container;
}

void main() {
  testWidgets(
      'a ticked item stays ticked on the same ingredient after the '
      'list shrinks', (WidgetTester tester) async {
    final ProviderContainer container = await _pumpPage(
      tester,
      <ShoppingItem>[_item('Apple'), _item('Banana'), _item('Carrot')],
    );

    await tester.tap(find.text('Carrot'));
    await tester.pump();
    expect(_checked(tester, 'Carrot'), isTrue);

    // Unfavoriting a meal drops "Apple", shifting every row up one index.
    container.read(_items.notifier).state = <ShoppingItem>[
      _item('Banana'),
      _item('Carrot'),
    ];
    await tester.pump();

    expect(
      _checked(tester, 'Carrot'),
      isTrue,
      reason: 'tick must follow Carrot',
    );
    expect(_checked(tester, 'Banana'), isFalse, reason: 'tick must not shift');
  });

  testWidgets(
      'removing a ticked item does not leak its tick onto its '
      'successor', (WidgetTester tester) async {
    final ProviderContainer container = await _pumpPage(
      tester,
      <ShoppingItem>[_item('Apple'), _item('Banana')],
    );

    await tester.tap(find.text('Apple'));
    await tester.pump();

    container.read(_items.notifier).state = <ShoppingItem>[_item('Banana')];
    await tester.pump();

    expect(find.text('Apple'), findsNothing);
    expect(_checked(tester, 'Banana'), isFalse);
  });

  testWidgets('ticking is case-insensitive on the ingredient name',
      (WidgetTester tester) async {
    final ProviderContainer container = await _pumpPage(
      tester,
      <ShoppingItem>[_item('Salt')],
    );

    await tester.tap(find.text('Salt'));
    await tester.pump();

    expect(container.read(checkedItemsProvider), <String>{'salt'});
  });
}
