import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'dart:ui';
import '../controllers/auth_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final RxInt _currentIndex = 0.obs;

  // Make screens lazy loaded and observable
  final Rx<List<Widget>> _screens = Rx<List<Widget>>([]);
  
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      label: 'Home',
    ),
    NavigationItem(
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize screens
    _screens.value = [
      const DashboardScreen(),
      const ProfileScreen(),
    ];

    // Ensure auth controller is initialized
    Get.put(AuthController());
    
    // Add a small delay to ensure proper initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex.value) {
      _currentIndex.value = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // Main content - no animation
          _screens.value[_currentIndex.value],
          
          // Bottom Navigation Bar
          Positioned(
            bottom: 10,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 65,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _navigationItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isActive = index == _currentIndex.value;
                      
                      return GestureDetector(
                        onTap: () => _onTabTapped(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          padding: EdgeInsets.symmetric(
                            horizontal: isActive ? 20 : 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Color(AppConstants.primaryColorHex).withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  isActive ? item.activeIcon : item.icon,
                                  color: isActive 
                                      ? Color(AppConstants.primaryColorHex)
                                      : Colors.grey.shade600,
                                  size: isActive ? 24 : 22,
                                ),
                              ),
                              if (isActive) ...[
                                const SizedBox(width: 8),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: TextStyle(
                                    color: Color(AppConstants.primaryColorHex),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  child: Text(item.label),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}