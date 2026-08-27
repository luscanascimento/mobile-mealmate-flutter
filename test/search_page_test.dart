import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealmate/features/meals/data/models/meal.dart';
import 'package:mealmate/features/meals/data/repositories/meal_repository.dart';
import 'package:mealmate/features/meals/presentation/providers/meal_providers.dart';
import 'package:mealmate/features/search/presentation/pages/search_page.dart';
import 'package:mocktail/mocktail.dart';

class _MockMealRepository extends Mock implements MealRepository {}

/// Must stay in sync with the debounce in [SearchPage].
const Duration _debounce = Duration(milliseconds: 400);

void main() {
  late _MockMealRepository repo;

  setUp(() {
    repo = _MockMealRepository();
    when(() => repo.search(any())).thenAnswer((_) async => const <Meal>[]);
  });

  Future<void> pumpSearch(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          mealRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: SearchPage()),
      ),
    );
  }

  testWidgets('fires one search for a burst of keystrokes, after the debounce',
      (WidgetTester tester) async {
    await pumpSearch(tester);
    final Finder field = find.byType(TextField);

    for (final String text in <String>['c', 'ch', 'chi', 'chic']) {
      await tester.enterText(field, text);
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Still inside the debounce window: nothing should have been requested.
    verifyNever(() => repo.search(any()));

    await tester.pump(_debounce);
    await tester.pump();

    final List<dynamic> queries =
        verify(() => repo.search(captureAny())).captured;
    expect(queries, <String>['chic']);
  });

  testWidgets('does not search until two characters are typed',
      (WidgetTester tester) async {
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'c');
    await tester.pump(_debounce);
    await tester.pump();

    verifyNever(() => repo.search(any()));
    expect(
      find.text('Type at least two characters to search recipes.'),
      findsOneWidget,
    );
  });

  testWidgets('clearing the field cancels a pending debounced search',
      (WidgetTester tester) async {
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'chicken');
    await tester.pump(_debounce);
    await tester.pump();
    verify(() => repo.search('chicken')).called(1);

    await tester.enterText(find.byType(TextField), 'beef');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump(_debounce);
    await tester.pump();

    verifyNever(() => repo.search(any()));
  });
}
