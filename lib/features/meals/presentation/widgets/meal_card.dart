import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/meal_summary.dart';

/// A tappable meal card used in category and search grids.
class MealCard extends StatelessWidget {
  const MealCard({required this.meal, this.trailing, super.key});

  final MealSummary meal;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoutes.mealDetail,
          pathParameters: <String, String>{'id': meal.id},
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  AppNetworkImage(url: meal.thumbnail),
                  if (trailing != null)
                    Positioned(top: 4, right: 4, child: trailing!),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                meal.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
