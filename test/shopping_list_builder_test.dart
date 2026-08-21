import 'package:flutter_test/flutter_test.dart';
import 'package:mealmate/features/meals/data/models/ingredient.dart';
import 'package:mealmate/features/meals/data/models/meal.dart';
import 'package:mealmate/features/shopping_list/domain/shopping_item.dart';
import 'package:mealmate/features/shopping_list/domain/shopping_list_builder.dart';

Meal _meal(String id, String name, List<Ingredient> ingredients) => Meal(
      id: id,
      name: name,
      ingredients: ingredients,
    );

void main() {
  const ShoppingListBuilder builder = ShoppingListBuilder();

  test('returns empty list when there are no favorites', () {
    expect(builder.build(const <Meal>[]), isEmpty);
  });

  test('de-duplicates ingredients case-insensitively', () {
    final List<Meal> favorites = <Meal>[
      _meal('1', 'A', const <Ingredient>[
        Ingredient(name: 'Salt', measure: '1 tsp'),
      ]),
      _meal('2', 'B', const <Ingredient>[
        Ingredient(name: 'salt', measure: '1 tsp'),
      ]),
    ];

    final List<ShoppingItem> items = builder.build(favorites);

    expect(items, hasLength(1));
    expect(items.first.name, 'Salt');
    // Same measure collapses to one entry.
    expect(items.first.measures, <String>['1 tsp']);
    expect(items.first.mealCount, 2);
  });

  test('preserves distinct measures for the same ingredient', () {
    final List<Meal> favorites = <Meal>[
      _meal('1', 'A', const <Ingredient>[
        Ingredient(name: 'Flour', measure: '200g'),
      ]),
      _meal('2', 'B', const <Ingredient>[
        Ingredient(name: 'Flour', measure: '1 cup'),
      ]),
    ];

    final List<ShoppingItem> items = builder.build(favorites);

    expect(items, hasLength(1));
    expect(items.first.measures, containsAll(<String>['200g', '1 cup']));
    expect(items.first.measuresLabel, contains(' + '));
  });

  test('handles ingredients without measures', () {
    final List<Meal> favorites = <Meal>[
      _meal('1', 'A', const <Ingredient>[
        Ingredient(name: 'Pepper', measure: ''),
      ]),
    ];

    final ShoppingItem item = builder.build(favorites).single;
    expect(item.hasMeasures, isFalse);
    expect(item.measures, isEmpty);
  });

  test('sorts output alphabetically', () {
    final List<Meal> favorites = <Meal>[
      _meal('1', 'A', const <Ingredient>[
        Ingredient(name: 'Zucchini', measure: '1'),
        Ingredient(name: 'Apple', measure: '2'),
      ]),
    ];

    final List<ShoppingItem> items = builder.build(favorites);
    expect(items.map((ShoppingItem e) => e.name), <String>['Apple', 'Zucchini']);
  });

  test('counts a meal once per ingredient even if repeated internally', () {
    final List<Meal> favorites = <Meal>[
      _meal('1', 'A', const <Ingredient>[
        Ingredient(name: 'Egg', measure: '1'),
        Ingredient(name: 'egg', measure: '2'),
      ]),
    ];

    final ShoppingItem item = builder.build(favorites).single;
    expect(item.mealCount, 1);
    expect(item.measures, containsAll(<String>['1', '2']));
  });
}
