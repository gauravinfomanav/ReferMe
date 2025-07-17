class AppConstants {
  // App Info
  static const String appName = 'ReferMe';
  static const String newFontFamily = 'Poppins';
  
  // Colors
  static const int primaryColorHex = 0xFF022D5C;
  static const int backgroundColorHex = 0xFFF8F9FA;
  
  // API Configuration
  static const String baseUrl = 'http://142.93.212.235:5006';
  
  // Shared Preferences Keys
  static const String tokenKey = 'token';
  static const String userDataKey = 'user_data';
  
  // API Headers
  static const String authorizationHeader = 'Authorization';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  static const int fadeAnimationDuration = 800;
  static const int splashDuration = 3000;
  static const String appTagline = 'Connect • Share • Grow';
} 