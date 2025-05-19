import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

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

  /// Optional: Fetch full user details from backend
  Future<void> loadUser() async {
    if (_userId != null) {
      user = await ApiService.getUserById(_userId!);
      notifyListeners();
    }
  }
}

