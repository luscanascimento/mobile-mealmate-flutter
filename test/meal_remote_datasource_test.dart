import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealmate/core/config/api_config.dart';
import 'package:mealmate/core/network/api_exception.dart';
import 'package:mealmate/features/meals/data/datasources/meal_remote_datasource.dart';
import 'package:mealmate/features/meals/data/models/meal.dart';
import 'package:mealmate/features/meals/data/models/meal_summary.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

final RequestOptions _requestOptions = RequestOptions(path: '/');

Response<dynamic> _ok(Object? data) => Response<dynamic>(
      requestOptions: _requestOptions,
      statusCode: 200,
      data: data,
    );

void main() {
  late _MockDio dio;
  late MealRemoteDataSource source;

  setUp(() {
    dio = _MockDio();
    source = MealRemoteDataSource(dio);
  });

  void stubGet(Object? Function() answer) {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => _ok(answer()));
  }

  void stubThrow(DioException error) {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(error);
  }

  group('parsing', () {
    test('searchByName hits search.php and folds flat ingredient pairs',
        () async {
      stubGet(
        () => <String, dynamic>{
          'meals': <dynamic>[
            <String, dynamic>{
              'idMeal': '52772',
              'strMeal': 'Teriyaki Chicken',
              'strIngredient1': 'Soy Sauce',
              'strMeasure1': '3/4 cup',
              'strIngredient2': '  ',
            },
          ],
        },
      );

      final List<Meal> meals = await source.searchByName('chicken');

      expect(meals, hasLength(1));
      expect(meals.single.name, 'Teriyaki Chicken');
      expect(meals.single.ingredients, hasLength(1));
      expect(meals.single.ingredients.single.name, 'Soy Sauce');

      final List<dynamic> captured = verify(
        () => dio.get<dynamic>(
          captureAny(),
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;
      expect(captured[0], ApiConfig.searchByName);
      expect(captured[1], <String, dynamic>{'s': 'chicken'});
    });

    test('mealsByCategory parses the summary shape', () async {
      stubGet(
        () => <String, dynamic>{
          'meals': <dynamic>[
            <String, dynamic>{
              'idMeal': '1',
              'strMeal': 'Pancakes',
              'strMealThumb': 'https://example.com/p.jpg',
            },
          ],
        },
      );

      final List<MealSummary> meals = await source.mealsByCategory('Dessert');

      expect(meals.single.id, '1');
      expect(meals.single.thumbnail, 'https://example.com/p.jpg');
    });

    test('treats {"meals": null} as no results, not an error', () async {
      stubGet(() => <String, dynamic>{'meals': null});

      expect(await source.searchByName('zzzz'), isEmpty);
      expect(await source.mealById('999'), isNull);
      expect(await source.randomMeal(), isNull);
    });

    test('skips non-object entries inside the meals array', () async {
      stubGet(
        () => <String, dynamic>{
          'meals': <dynamic>[
            'garbage',
            <String, dynamic>{'idMeal': '7', 'strMeal': 'Real'},
          ],
        },
      );

      final List<Meal> meals = await source.searchByName('x');
      expect(meals.map((Meal m) => m.id), <String>['7']);
    });

    test('throws ApiException when the body is not a JSON object', () async {
      stubGet(() => 'not json');

      expect(
        () => source.randomMeal(),
        throwsA(
          isA<ApiException>().having(
            (ApiException e) => e.message,
            'message',
            'Unexpected response format.',
          ),
        ),
      );
    });
  });

  group('Dio error mapping', () {
    Future<ApiException> capture(DioExceptionType type, {int? status}) async {
      stubThrow(
        DioException(
          requestOptions: _requestOptions,
          type: type,
          response: status == null
              ? null
              : Response<dynamic>(
                  requestOptions: _requestOptions,
                  statusCode: status,
                ),
        ),
      );
      try {
        await source.randomMeal();
      } on ApiException catch (e) {
        return e;
      }
      fail('expected an ApiException for $type');
    }

    test('timeouts map to the network-check message', () async {
      for (final DioExceptionType type in <DioExceptionType>[
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect((await capture(type)).message, contains('timed out'));
      }
    });

    test('connectionError maps to the offline message', () async {
      expect(
        (await capture(DioExceptionType.connectionError)).message,
        contains('internet connection'),
      );
    });

    test('badCertificate maps to the insecure-connection message', () async {
      expect(
        (await capture(DioExceptionType.badCertificate)).message,
        'Insecure connection was blocked.',
      );
    });

    test('badResponse keeps the status code but hides server internals',
        () async {
      final ApiException error =
          await capture(DioExceptionType.badResponse, status: 503);
      expect(error.statusCode, 503);
      expect(
          error.message,
          'The server responded with an error. '
          'Please try again later.');
    });

    test('unknown maps to the generic fallback', () async {
      final ApiException error = await capture(DioExceptionType.unknown);
      expect(error.message, 'Something went wrong. Please try again.');
      expect(error.statusCode, isNull);
    });
  });
}
