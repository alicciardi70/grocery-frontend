import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? _userId;
  User? user;

  String? get userId => _userId;

  /// Manually set user (e.g. for dev mode)
  void setUser(User newUser) {
    user = newUser;
    _userId = newUser.id;
    notifyListeners();
  }

  /// Login by user ID only (used if loading user later)
  void login(String userId) {
    _userId = userId;
    notifyListeners();
  }

  /// Clear current user
  void logout() {
    _userId = null;
    user = null;
    notifyListeners();
  }

  /// Login with email/password
  Future<void> loginWithCredentials(String email, String password) async {
    user = await ApiService.loginUser(email: email, password: password);
    _userId = user?.id;
    notifyListeners();
  }

  // Register New User
  Future<void> registerNewUser({
    required String username,
    required String email,
    required String password,
    String? phone,
    String? fullName,
  }) async {
    user = await ApiService.registerUser(
      username: username,
      email: email,
      password: password,
      phone: phone,
      fullName: fullName,
    );
    _userId = user?.id;
    notifyListeners();
  }

  /// Optional: Fetch full user details from backend
  Future<void> loadUser() async {
    if (_userId != null) {
      user = await ApiService.getUserById(_userId!);
      notifyListeners();
    }
  }

  /// Persist user ID to shared preferences
  Future<void> persistUser(User newUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', newUser.id);
    setUser(newUser);
  }

  /// Clear saved user from shared preferences and reset state
  Future<void> clearSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    logout();
  }
}
