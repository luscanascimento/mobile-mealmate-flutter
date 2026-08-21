import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../meals/data/models/meal.dart';
import '../../../meals/presentation/widgets/meal_card.dart';
import '../providers/favorites_providers.dart';
import '../widgets/favorite_button.dart';

/// Lists all locally-saved favorite meals.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Meal> favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favorites.isEmpty
          ? const EmptyStateView(
              title: 'No favorites yet',
              message:
                  'Tap the heart on any recipe to save it here for offline access.',
              icon: Icons.favorite_border,
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.gridColumns(context),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (BuildContext context, int index) {
                final Meal meal = favorites[index];
                return MealCard(
                  meal: meal.toSummary(),
                  trailing: FavoriteButton(meal: meal, filledBackground: true),
                );
              },
            ),
    );
  }
}
