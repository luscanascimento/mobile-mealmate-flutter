import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../../meals/data/models/meal.dart';
import '../providers/surprise_providers.dart';

/// "Surprise Me" random meal roulette.
///
/// Tapping the button spins a fun animation and lands on a fresh random recipe
/// fetched from TheMealDB `random.php`.
class SurprisePage extends ConsumerStatefulWidget {
  const SurprisePage({super.key});

  @override
  ConsumerState<SurprisePage> createState() => _SurprisePageState();
}

class _SurprisePageState extends ConsumerState<SurprisePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  bool _hasSpunOnce = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    setState(() => _hasSpunOnce = true);
    _spinController.reset();
    unawaited(_spinController.repeat());
    // Trigger a fresh fetch.
    ref.invalidate(randomMealProvider);
    // Ensure the spinner shows for at least one full, satisfying rotation.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    // Wait for the data to actually resolve before settling the animation.
    await ref.read(randomMealProvider.future).catchError((Object _) => null);
    if (!mounted) return;
    // Rebuild so the result (rather than the spinner) is shown once the
    // controller is no longer animating.
    setState(_spinController.stop);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Meal?> meal = ref.watch(randomMealProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Surprise Me')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              Expanded(child: _buildStage(meal)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: meal.isLoading ? null : _spin,
                  icon: const Icon(Icons.casino),
                  label: Text(_hasSpunOnce ? 'Spin again' : 'Surprise me!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStage(AsyncValue<Meal?> meal) {
    if (!_hasSpunOnce) {
      return const _Idle();
    }

    return meal.when(
      loading: () => _Roulette(controller: _spinController),
      error: (Object error, StackTrace _) => ErrorStateView(
        message: error.toString(),
        onRetry: _spin,
      ),
      data: (Meal? value) {
        if (_spinController.isAnimating) {
          return _Roulette(controller: _spinController);
        }
        if (value == null) {
          return const EmptyStateView(
            title: 'No luck',
            message: 'Could not fetch a random meal. Try again!',
            icon: Icons.casino_outlined,
          );
        }
        return _Result(meal: value);
      },
    );
  }
}

class _Idle extends StatelessWidget {
  const _Idle();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.casino, size: 96, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Feeling adventurous?',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Spin the roulette to discover a random recipe.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Roulette extends StatelessWidget {
  const _Roulette({required this.controller});
  final AnimationController controller;

  static const List<IconData> _icons = <IconData>[
    Icons.local_pizza,
    Icons.ramen_dining,
    Icons.lunch_dining,
    Icons.bakery_dining,
    Icons.icecream,
    Icons.set_meal,
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RotationTransition(
            turns: controller,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: <Color>[
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                    theme.colorScheme.secondary,
                    theme.colorScheme.primary,
                  ],
                ),
              ),
              child: AnimatedBuilder(
                animation: controller,
                builder: (BuildContext context, Widget? child) {
                  final int index = (controller.value * _icons.length).floor() %
                      _icons.length;
                  return Center(
                    child: Icon(
                      _icons[index],
                      size: 64,
                      color: theme.colorScheme.onPrimary,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Finding something tasty...',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.meal});
  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    AppNetworkImage(url: meal.thumbnail),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FavoriteButton(
                        meal: meal,
                        filledBackground: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              meal.name,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (meal.category != null || meal.area != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                <String?>[meal.category, meal.area]
                    .whereType<String>()
                    .join(' • '),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.pushNamed(
                AppRoutes.mealDetail,
                pathParameters: <String, String>{'id': meal.id},
              ),
              icon: const Icon(Icons.receipt_long),
              label: const Text('View full recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
