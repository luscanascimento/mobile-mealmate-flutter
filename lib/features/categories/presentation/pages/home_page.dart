import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/grid_shimmer.dart';
import '../../../../core/widgets/state_views.dart';
import '../../data/models/category.dart';
import '../providers/category_providers.dart';
import '../widgets/category_card.dart';

/// Landing page: browse meals by category.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Category>> categories =
        ref.watch(categoriesProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MealMate'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(categoriesProvider.future),
        child: categories.when(
          loading: () => const GridShimmer(),
          error: (Object error, StackTrace _) => ListView(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.7,
                child: ErrorStateView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(categoriesProvider),
                ),
              ),
            ],
          ),
          data: (List<Category> items) {
            if (items.isEmpty) {
              return const EmptyStateView(
                title: 'No categories',
                message: 'We could not find any categories right now.',
                icon: Icons.category_outlined,
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.gridColumns(context),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (BuildContext context, int index) =>
                  CategoryCard(category: items[index]),
            );
          },
        ),
      ),
    );
  }
}
