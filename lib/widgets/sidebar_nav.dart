import 'package:flutter/material.dart';

class SidebarNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const SidebarNav({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(Icons.shopping_cart, size: 32),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.search),
          label: Text('Search'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.shopping_basket),
          label: Text('My Baskets'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }
}
