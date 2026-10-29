import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/presentation/home_screen.dart';
import '../../levels/presentation/level_select_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../controller/navigation_controller.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.put(NavigationController());

    final screens = const [
      HomeScreen(),
      LevelSelectScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navController.currentIndex.value,
          children: screens,
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: navController.currentIndex.value,
            onDestinationSelected: navController.changeIndex,
            indicatorColor: AppColors.primary.withValues(alpha: 0.5),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppColors.textMuted),
                selectedIcon: Icon(Icons.home_rounded, color: Colors.white),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined, color: AppColors.textMuted),
                selectedIcon: Icon(Icons.grid_view_rounded, color: Colors.white),
                label: 'Levels',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
                selectedIcon: Icon(Icons.person_rounded, color: Colors.white),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

