import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/grid_shimmer.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../meals/data/models/meal_summary.dart';
import '../../../meals/presentation/providers/meal_providers.dart';
import '../../../meals/presentation/widgets/meal_card.dart';

/// Shows all meals within a chosen category.
class CategoryMealsPage extends ConsumerWidget {
  const CategoryMealsPage({required this.categoryName, super.key});

  final String categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<MealSummary>> meals =
        ref.watch(mealsByCategoryProvider(categoryName));

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: meals.when(
        loading: () => const GridShimmer(),
        error: (Object error, StackTrace _) => ErrorStateView(
          message: error.toString(),
          onRetry: () => ref.invalidate(mealsByCategoryProvider(categoryName)),
        ),
        data: (List<MealSummary> items) {
          if (items.isEmpty) {
            return const EmptyStateView(
              title: 'No meals here',
              message: 'This category has no meals right now.',
              icon: Icons.no_meals_outlined,
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.gridColumns(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (BuildContext context, int index) =>
                MealCard(meal: items[index]),
          );
        },
      ),
    );
  }
}
