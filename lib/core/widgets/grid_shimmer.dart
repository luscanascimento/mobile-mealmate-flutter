import 'package:flutter/material.dart';

import '../utils/responsive.dart';
import 'shimmer_box.dart';

/// A grid of shimmering placeholders shown while a list of cards loads.
class GridShimmer extends StatelessWidget {
  const GridShimmer({this.itemCount = 8, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.gridColumns(context),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (BuildContext context, int index) => const ShimmerBox(
        borderRadius: 20,
      ),
    );
  }
}
