import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final User? user = userProvider.user;
    final String? userId = userProvider.userId;

    if (userId == null) {
      return const Center(child: Text("No user logged in"));
    }

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Profile",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.person),
              const SizedBox(width: 12),
              Text(
                user.fullName ?? user.username,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _profileField("Username", user.username),
          _profileField("Email", user.email),
          if (user.phone != null) _profileField("Phone", user.phone!),
          _profileField("Status", user.isActive ? "Active" : "Inactive"),
          _profileField("User ID", user.id),
          _profileField(
            "Joined",
            user.createdAt.toLocal().toString().split(".").first,
          ),
          const Spacer(),
          const Divider(),
          const Text(
            "Version 7",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const Text(
            "Future Options:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            "• Sign out\n• Change password\n• Update profile\n• View history",
          ),
        ],
      ),
    );
  }

  Widget _profileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
