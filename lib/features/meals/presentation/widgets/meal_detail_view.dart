import 'package:flutter/material.dart';

import '../../../../core/utils/url_helper.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../data/models/ingredient.dart';
import '../../data/models/meal.dart';

/// Renders a fully-loaded [Meal]: hero image, meta chips, ingredients with
/// measures, numbered steps and an optional YouTube link.
class MealDetailView extends StatelessWidget {
  const MealDetailView({required this.meal, super.key});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> steps = meal.steps;

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          actions: <Widget>[FavoriteButton(meal: meal)],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              meal.name,
              style: const TextStyle(
                shadows: <Shadow>[
                  Shadow(blurRadius: 8, color: Colors.black87),
                ],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                AppNetworkImage(url: meal.thumbnail),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _MetaChips(meal: meal),
                if (meal.hasYoutube) ...<Widget>[
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        UrlHelper.openExternal(context, meal.youtubeUrl),
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Watch on YouTube'),
                  ),
                ],
                const SizedBox(height: 24),
                const _SectionTitle('Ingredients', icon: Icons.shopping_basket_outlined),
                const SizedBox(height: 8),
                _Ingredients(ingredients: meal.ingredients),
                const SizedBox(height: 24),
                const _SectionTitle('Instructions', icon: Icons.list_alt),
                const SizedBox(height: 8),
                if (steps.isEmpty)
                  Text(
                    'No instructions provided.',
                    style: theme.textTheme.bodyMedium,
                  )
                else
                  _Steps(steps: steps),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChips extends StatelessWidget {
  const _MetaChips({required this.meal});
  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = <Widget>[
      if (meal.category != null)
        Chip(
          avatar: const Icon(Icons.category_outlined, size: 18),
          label: Text(meal.category!),
        ),
      if (meal.area != null)
        Chip(
          avatar: const Icon(Icons.public, size: 18),
          label: Text(meal.area!),
        ),
      ...meal.tags.map((String tag) => Chip(label: Text('#$tag'))),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }
}

class _Ingredients extends StatelessWidget {
  const _Ingredients({required this.ingredients});
  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return Text(
        'No ingredients listed.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    final ThemeData theme = Theme.of(context);
    return Column(
      children: ingredients.map((Ingredient ingredient) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: <Widget>[
              Icon(Icons.check_circle_outline,
                  size: 20, color: theme.colorScheme.primary,),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ingredient.name,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              if (ingredient.measure.isNotEmpty)
                Text(
                  ingredient.measure,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.steps});
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: List<Widget>.generate(steps.length, (int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 14,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(steps[index], style: theme.textTheme.bodyLarge),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
