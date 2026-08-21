import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/categories/presentation/pages/category_meals_page.dart';
import '../../features/categories/presentation/pages/home_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/meals/presentation/pages/meal_detail_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/shopping_list/presentation/pages/shopping_list_page.dart';
import '../../features/surprise/presentation/pages/surprise_page.dart';
import '../widgets/scaffold_with_nav.dart';

/// Centralized route names to avoid magic strings across the app.
abstract final class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String surprise = '/surprise';
  static const String favorites = '/favorites';
  static const String shoppingList = '/shopping-list';

  static const String categoryMeals = 'category-meals';
  static const String mealDetail = 'meal-detail';
}

/// Builds the app's [GoRouter].
///
/// A [StatefulShellRoute] gives each bottom-nav tab its own navigation stack,
/// so deep navigation in one tab is preserved when switching tabs.
GoRouter createRouter() {
  final GlobalKey<NavigatorState> rootKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell shell,
        ) =>
            ScaffoldWithNav(shell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (BuildContext context, GoRouterState state) =>
                    const HomePage(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'category/:name',
                    name: AppRoutes.categoryMeals,
                    parentNavigatorKey: rootKey,
                    builder: (BuildContext context, GoRouterState state) {
                      final String name =
                          state.pathParameters['name'] ?? '';
                      return CategoryMealsPage(categoryName: name);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.search,
                builder: (BuildContext context, GoRouterState state) =>
                    const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.surprise,
                builder: (BuildContext context, GoRouterState state) =>
                    const SurprisePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.favorites,
                builder: (BuildContext context, GoRouterState state) =>
                    const FavoritesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.shoppingList,
                builder: (BuildContext context, GoRouterState state) =>
                    const ShoppingListPage(),
              ),
            ],
          ),
        ],
      ),
      // Meal detail is a root-level route so it covers the bottom nav.
      GoRoute(
        path: '/meal/:id',
        name: AppRoutes.mealDetail,
        parentNavigatorKey: rootKey,
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['id'] ?? '';
          return MealDetailPage(mealId: id);
        },
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}
