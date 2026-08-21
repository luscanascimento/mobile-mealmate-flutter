import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mealmate/features/favorites/data/favorites_repository.dart';
import 'package:mealmate/features/meals/data/models/ingredient.dart';
import 'package:mealmate/features/meals/data/models/meal.dart';

void main() {
  late Directory tempDir;
  late Box<String> box;
  late FavoritesRepository repository;

  const Meal meal = Meal(
    id: '1',
    name: 'Pancakes',
    ingredients: <Ingredient>[
      Ingredient(name: 'Flour', measure: '200g'),
    ],
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mealmate_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<String>('favorites_test');
    repository = FavoritesRepository(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('favorites_test');
    await tempDir.delete(recursive: true);
  });

  test('adds and detects a favorite', () async {
    expect(repository.isFavorite('1'), isFalse);
    await repository.add(meal);
    expect(repository.isFavorite('1'), isTrue);
    expect(repository.getAll(), <Meal>[meal]);
  });

  test('toggle returns new state and persists it', () async {
    final bool added = await repository.toggle(meal);
    expect(added, isTrue);
    expect(repository.isFavorite('1'), isTrue);

    final bool removed = await repository.toggle(meal);
    expect(removed, isFalse);
    expect(repository.isFavorite('1'), isFalse);
  });

  test('survives reopening the box (persistence)', () async {
    await repository.add(meal);
    await box.close();

    box = await Hive.openBox<String>('favorites_test');
    repository = FavoritesRepository(box);

    final List<Meal> restored = repository.getAll();
    expect(restored, hasLength(1));
    expect(restored.first.name, 'Pancakes');
    expect(restored.first.ingredients.first.measure, '200g');
  });
}
