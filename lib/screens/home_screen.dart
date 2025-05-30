import 'package:flutter/material.dart';
import 'product_search_screen.dart';
import 'baskets_screen.dart';
import 'profile_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/sidebar_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<Widget> _pages = [
    ProductSearchScreen(),
    BasketsScreen(),
    ProfileScreen(),
  ];

  void onSelectPage(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.loadUser();
    });
  }


  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            SidebarNav(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelectPage,
            ),
          Expanded(child: _pages[selectedIndex]),
        ],
      ),
      bottomNavigationBar: !isWide
          ? NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelectPage,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
                NavigationDestination(icon: Icon(Icons.shopping_basket), label: 'Baskets'),
                NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
              ],
            )
          : null,
    );
  }
}