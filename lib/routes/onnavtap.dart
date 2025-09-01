// This method is extracted into a reusable function that can be used in any screen
// that needs profile-aware navigation
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inddigipay/routes/login.dart';

/// Navigation handler that includes authentication check for profile tab.
/// Returns immediately for non-profile tabs.
Future<void> onNavTap(BuildContext context, int index, void Function(int) onIndexChange) async {
  if (index == 1) { // Profile tab index
    // Switch to profile tab immediately for better UX
    onIndexChange(index);
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    if (token == null || token.isEmpty) {
      // Show login page as a full-screen dialog
      final loginResult = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginpageApp(),
          fullscreenDialog: true,
        ),
      );
      
      if (loginResult != true) {
        // User cancelled login or login failed, go back to home
        onIndexChange(0);
      }
    }
  } else {
    onIndexChange(index);
  }
}
