import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
import 'login.dart';

class ProfileRedirector extends StatelessWidget {
  const ProfileRedirector({super.key});

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) {
          // Already logged in
          Future.microtask(() => Navigator.pushReplacementNamed(context, '/dashboard'));
        } else {
          // Not logged in
          Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
