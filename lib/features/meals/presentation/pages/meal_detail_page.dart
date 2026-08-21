import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/state_views.dart';
import '../../data/models/meal.dart';
import '../providers/meal_providers.dart';
import '../widgets/meal_detail_view.dart';

/// Full recipe detail page loaded by meal id.
class MealDetailPage extends ConsumerWidget {
  const MealDetailPage({required this.mealId, super.key});

  final String mealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Meal?> meal = ref.watch(mealDetailProvider(mealId));

    return Scaffold(
      body: meal.when(
        loading: () => const _DetailLoading(),
        error: (Object error, StackTrace _) => SafeArea(
          child: ErrorStateView(
            message: error.toString(),
            onRetry: () => ref.invalidate(mealDetailProvider(mealId)),
          ),
        ),
        data: (Meal? value) {
          if (value == null) {
            return const SafeArea(
              child: EmptyStateView(
                title: 'Recipe not found',
                message: 'We could not load this recipe.',
                icon: Icons.search_off,
              ),
            );
          }
          return MealDetailView(meal: value);
        },
      ),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
