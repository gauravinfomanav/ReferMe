import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:referme/screens/dashboard_screen.dart';
import 'package:referme/screens/login_screen.dart';
import 'package:referme/screens/main_screen.dart';
import 'package:referme/screens/select_card_screen.dart';
import '../constants/app_constants.dart';
import '../controllers/auth_controller.dart';
import '../controllers/card_selection_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _lottieController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: AppConstants.fadeAnimationDuration),
      vsync: this,
    );

    // Create fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Create slide animation
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _lottieController.repeat();

    // Navigate after animation
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    try {
      await Future.delayed(Duration(milliseconds: AppConstants.splashDuration));
      
      final authController = Get.put(AuthController());
      await authController.checkLoginStatus(); // Wait for auth check
      
      if (!authController.isLoggedIn) {
        Get.offAll(() => const LoginScreen());
        return;
      }

      // If user is already logged in, go to main screen
      // Preference check will be handled after login
      Get.offAll(() => const MainScreen());
    } catch (e) {
      print('Navigation error: $e');
      // If any error occurs, safely navigate to login
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColorHex),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive sizes
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            
            // Dynamic animation size based on screen width
            final animationSize = screenWidth * 0.7;
            
            // Dynamic text sizes
            final titleSize = screenWidth * 0.1; // 10% of screen width
            final taglineSize = screenWidth * 0.04; // 4% of screen width
            
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _fadeController,
                  curve: Curves.easeOutCubic,
                )),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: SizedBox(
                    height: screenHeight,
                    child: Column(
                      children: [
                        // Top spacer - more flexible
                        Expanded(
                          flex: 2,
                          child: Container(),
                        ),
                        
                        // Main content section
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08, // 8% padding
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Lottie Animation with responsive size
                                SizedBox(
                                  height: animationSize,
                                  width: animationSize,
                                  child: Lottie.asset(
                                    'resources/images/referral_animation.json',
                                    controller: _lottieController,
                                    fit: BoxFit.contain,
                                    repeat: true,
                                  ),
                                ),
                                
                                SizedBox(height: screenHeight * 0.03),
                                
                                // App Title with responsive size
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    AppConstants.appName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: AppConstants.newFontFamily,
                                      fontSize: titleSize.clamp(24.0, 42.0),
                                      fontWeight: FontWeight.w700,
                                      color: Color(AppConstants.primaryColorHex),
                                      letterSpacing: -0.5,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: screenHeight * 0.01),
                                
                                // Tagline with responsive size
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    AppConstants.appTagline,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: taglineSize.clamp(12.0, 16.0),
                                      fontFamily: AppConstants.newFontFamily,
                                      fontWeight: FontWeight.w400,
                                      color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                                      letterSpacing: 0.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Bottom section with simple loader
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Simple dot loader
                              const SizedBox(
                                width: 60,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _DotLoader(),
                                    _DotLoader(),
                                    _DotLoader(),
                                  ],
                                ),
                              ),
                              
                              SizedBox(height: screenHeight * 0.02),
                              
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  fontSize: (screenWidth * 0.035).clamp(12.0, 14.0),
                                  fontFamily: AppConstants.newFontFamily,
                                  fontWeight: FontWeight.w500,
                                  color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Custom dot loader widget
class _DotLoader extends StatefulWidget {
  const _DotLoader();

  @override
  State<_DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<_DotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
} 