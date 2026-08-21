import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/grid_shimmer.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../meals/data/models/meal.dart';
import '../../../meals/presentation/widgets/meal_card.dart';
import '../providers/search_providers.dart';

/// Search meals by name, with debounced input to limit API calls.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Meal>> results = ref.watch(searchResultsProvider);
    final String query = ref.watch(searchQueryProvider).trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search recipes, e.g. "chicken"',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _debounce?.cancel();
                          ref.read(searchQueryProvider.notifier).state = '';
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          Expanded(child: _buildResults(context, results, query)),
        ],
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    AsyncValue<List<Meal>> results,
    String query,
  ) {
    if (query.length < 2) {
      return const EmptyStateView(
        title: 'Find your next meal',
        message: 'Type at least two characters to search recipes.',
        icon: Icons.search,
      );
    }

    return results.when(
      loading: () => const GridShimmer(),
      error: (Object error, StackTrace _) => ErrorStateView(
        message: error.toString(),
        onRetry: () => ref.invalidate(searchResultsProvider),
      ),
      data: (List<Meal> items) {
        if (items.isEmpty) {
          return EmptyStateView(
            title: 'No results',
            message: 'No recipes matched "$query".',
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
              MealCard(meal: items[index].toSummary()),
        );
      },
    );
  }
}
