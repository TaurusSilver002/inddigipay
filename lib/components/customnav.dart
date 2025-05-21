import 'package:flutter/material.dart';
import 'package:inddigipay/config.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define specific actions for each tab
    void _handleNavigation(int index) {
      // First call the provided onTap callback
      onTap(index);
      
      // Then perform any additional actions based on which tab was tapped
      switch (index) {
        case 0: // Home tab
          // Add any specific functionality for the Home tab
          debugPrint('Home tab tapped with custom handler');
          break;
        case 1: // Profile tab
          // Redirect to profile
          Navigator.of(context).pushNamed('/profile');
          break;
        // Add more cases if you add more tabs
      }
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: _handleNavigation, // Use our custom handler
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}