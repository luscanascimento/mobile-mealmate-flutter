import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/responsive.dart';

/// App shell that hosts the [StatefulNavigationShell] and renders the primary
/// navigation.
///
/// On phones it uses a [NavigationBar] (bottom); on tablets it switches to a
/// [NavigationRail] for a more ergonomic wide-screen layout.
class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({required this.shell, super.key});

  final StatefulNavigationShell shell;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(Icons.explore_outlined, Icons.explore, 'Browse'),
    _NavItem(Icons.search_outlined, Icons.search, 'Search'),
    _NavItem(Icons.casino_outlined, Icons.casino, 'Surprise'),
    _NavItem(Icons.favorite_outline, Icons.favorite, 'Favorites'),
    _NavItem(
        Icons.shopping_cart_outlined, Icons.shopping_cart, 'Shopping',),
  ];

  void _onTap(int index) {
    shell.goBranch(
      index,
      // Tapping the active tab returns it to its initial route.
      initialLocation: index == shell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = Responsive.isTablet(context);

    if (tablet) {
      return Scaffold(
        body: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _onTap,
              labelType: NavigationRailLabelType.all,
              destinations: _items
                  .map(
                    (_NavItem item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: shell),
          ],
        ),
      );
    }

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: _items
            .map(
              (_NavItem item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
