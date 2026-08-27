import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealmate/core/network/api_exception.dart';
import 'package:mealmate/features/categories/presentation/pages/category_meals_page.dart';
import 'package:mealmate/features/meals/data/models/meal_summary.dart';
import 'package:mealmate/features/meals/presentation/providers/meal_providers.dart';

void main() {
  group('ApiException.messageFor', () {
    test('returns the friendly message, never the toString() form', () {
      const ApiException error = ApiException(
        'The server responded with an error. Please try again later.',
        statusCode: 500,
      );

      expect(
        ApiException.messageFor(error),
        'The server responded with an error. Please try again later.',
      );
      expect(ApiException.messageFor(error), isNot(contains('ApiException')));
      expect(ApiException.messageFor(error), isNot(contains('500')));
    });

    test('falls back to a generic message for unknown errors', () {
      expect(
        ApiException.messageFor(StateError('box not open')),
        'Something went wrong. Please try again.',
      );
    });
  });

  testWidgets('an error screen renders the friendly message, not the raw error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          mealsByCategoryProvider('Seafood').overrideWith(
            (Ref ref) => Future<List<MealSummary>>.error(
              const ApiException(
                'The server responded with an error. Please try again later.',
                statusCode: 500,
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          home: CategoryMealsPage(categoryName: 'Seafood'),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('ApiException'), findsNothing);
    expect(
      find.text('The server responded with an error. Please try again later.'),
      findsOneWidget,
    );
  });
}
