import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/ad_service.dart';
import 'home/home_screen.dart';
import 'library/library_screen.dart';
import 'downloads/downloads_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LibraryScreen(),
    DownloadsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primaryViolet.withOpacity(0.25),
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          if (index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });
            AdService.instance.registerNavigationTransition(context);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppColors.textSecondaryDark),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primaryViolet),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined, color: AppColors.textSecondaryDark),
            selectedIcon: Icon(Icons.video_library_rounded, color: AppColors.primaryViolet),
            label: 'Bibliothèque',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined, color: AppColors.textSecondaryDark),
            selectedIcon: Icon(Icons.download_rounded, color: AppColors.secondaryCyan),
            label: 'Télécharg.',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: AppColors.textSecondaryDark),
            selectedIcon: Icon(Icons.settings_rounded, color: AppColors.primaryViolet),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
