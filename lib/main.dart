import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedUserId = prefs.getString('userId');

  final userProvider = UserProvider();

  if (savedUserId != null) {
    userProvider.login(
      savedUserId,
    ); // this will trigger loadUser() in HomeScreen
  } else {
    // fallback to hardcoded dev user
    userProvider.setUser(
      User(
        id: 'fd2e49b3-e84e-4695-a118-2c0bef73b9e6',
        username: 'anthony351',
        email: 'anthony_licciardi@yahoo.com',
        fullName: 'Anthony',
        phone: '123-456-7890',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => userProvider,
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
