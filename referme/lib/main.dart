import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'constants/app_constants.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(
   // Enable device preview
      const MyApp(), // Wrap your app
    
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar style globally
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Dark icons for light background
        statusBarBrightness: Brightness.light, // For iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(AppConstants.primaryColorHex),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Color(AppConstants.backgroundColorHex),
        useMaterial3: true,
        fontFamily: AppConstants.newFontFamily,
        // Set app bar theme to ensure consistent status bar
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      home: const SplashScreen(),
      // home: const MainDashboardScreen(), // Uncomment this and comment SplashScreen when ready
    );
  }
}
