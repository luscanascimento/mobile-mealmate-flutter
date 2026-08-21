import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../meals/data/models/meal.dart';
import '../providers/favorites_providers.dart';

/// An animated heart toggle bound to the favorites store.
///
/// Requires the full [Meal] (not just an id) so the meal can be persisted for
/// offline favorites and the shopping-list aggregation.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({required this.meal, this.filledBackground = false, super.key});

  final Meal meal;
  final bool filledBackground;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFavorite = ref.watch(isFavoriteProvider(meal.id));
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final Widget icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (Widget child, Animation<double> animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        key: ValueKey<bool>(isFavorite),
        color: isFavorite ? scheme.error : null,
      ),
    );

    Future<void> onPressed() async {
      final bool nowFavorite =
          await ref.read(favoritesProvider.notifier).toggle(meal);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              nowFavorite
                  ? 'Added to favorites'
                  : 'Removed from favorites',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    }

    if (filledBackground) {
      return Material(
        color: scheme.surface.withValues(alpha: 0.85),
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
        ),
      );
    }

    return IconButton(
      onPressed: onPressed,
      icon: icon,
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
    );
  }
}
