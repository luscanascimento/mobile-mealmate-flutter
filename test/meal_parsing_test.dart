import 'package:flutter_test/flutter_test.dart';
import 'package:mealmate/features/meals/data/models/meal.dart';

void main() {
  group('Meal.fromJson', () {
    test('folds flat ingredient/measure pairs and skips empties', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'idMeal': '52772',
        'strMeal': 'Teriyaki Chicken',
        'strCategory': 'Chicken',
        'strArea': 'Japanese',
        'strInstructions': 'Step one.\r\nStep two.\n\nStep three.',
        'strMealThumb': 'https://example.com/img.jpg',
        'strYoutube': 'https://www.youtube.com/watch?v=abc',
        'strTags': 'Meat, Sauce ,',
        'strIngredient1': 'Chicken',
        'strMeasure1': '250g',
        'strIngredient2': 'Soy Sauce',
        'strMeasure2': '1 tbsp',
        // Empty pair should be skipped.
        'strIngredient3': '',
        'strMeasure3': ' ',
        // Ingredient with no measure should still be included.
        'strIngredient4': 'Ginger',
        'strMeasure4': '',
      };

      final Meal meal = Meal.fromJson(json);

      expect(meal.id, '52772');
      expect(meal.name, 'Teriyaki Chicken');
      expect(meal.category, 'Chicken');
      expect(meal.area, 'Japanese');
      expect(meal.ingredients, hasLength(3));
      expect(meal.ingredients.first.name, 'Chicken');
      expect(meal.ingredients.first.measure, '250g');
      expect(meal.ingredients.last.name, 'Ginger');
      expect(meal.ingredients.last.measure, isEmpty);
      expect(meal.tags, <String>['Meat', 'Sauce']);
      expect(meal.hasYoutube, isTrue);
    });

    test('splits instructions into non-empty trimmed steps', () {
      final Meal meal = Meal.fromJson(const <String, dynamic>{
        'idMeal': '1',
        'strMeal': 'Test',
        'strInstructions': ' First. \n\n Second. \r\n',
      });
      expect(meal.steps, <String>['First.', 'Second.']);
    });

    test('is defensive against missing fields', () {
      final Meal meal = Meal.fromJson(const <String, dynamic>{'idMeal': '9'});
      expect(meal.name, 'Unknown meal');
      expect(meal.ingredients, isEmpty);
      expect(meal.steps, isEmpty);
      expect(meal.hasYoutube, isFalse);
    });

    test('rejects non-https youtube url', () {
      final Meal meal = Meal.fromJson(const <String, dynamic>{
        'idMeal': '1',
        'strMeal': 'Test',
        'strYoutube': 'http://insecure.example.com',
      });
      expect(meal.hasYoutube, isFalse);
    });
  });

  group('Meal round-trip persistence', () {
    test('toJson/fromStoredJson preserves data', () {
      final Meal original = Meal.fromJson(const <String, dynamic>{
        'idMeal': '42',
        'strMeal': 'Round Trip',
        'strCategory': 'Dessert',
        'strIngredient1': 'Sugar',
        'strMeasure1': '100g',
      });

      final Meal restored = Meal.fromStoredJson(original.toJson());

      expect(restored, original);
    });
  });
}
