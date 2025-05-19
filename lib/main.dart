import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider()
        ..setUser(User(
          id: 'fd2e49b3-e84e-4695-a118-2c0bef73b9e6', 
          username: 'anthony351',
          email: 'anthony_licciardi@yahoo.com',
          fullName: 'Anthony',
          phone: '123-456-7890',
          isActive: true,
          createdAt: DateTime.now(),
        )),
      child: const GroceryScoutApp(),
    ),
  );
}

class GroceryScoutApp extends StatelessWidget {
  const GroceryScoutApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GroceryScout',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const HomeScreen(), // Includes the sidebar layout
    );
  }
}
