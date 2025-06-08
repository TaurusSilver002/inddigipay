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

  @override  Widget build(BuildContext context) {
    // Simply call the provided onTap callback
    void _handleNavigation(int index) {
      onTap(index);
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