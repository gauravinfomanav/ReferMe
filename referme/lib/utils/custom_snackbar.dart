import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  static void show({
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    Get.snackbar(
      '', // Empty title
      message,
      duration: duration,
      snackPosition: position,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      borderRadius: 12,
      borderWidth: 0,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      animationDuration: const Duration(milliseconds: 300),
      barBlur: 10,
      overlayBlur: 0,
      snackStyle: SnackStyle.FLOATING,
      titleText: const SizedBox.shrink(), // Hide title
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.center,
      ),
      shouldIconPulse: false,
      maxWidth: 400,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
    );
  }

  // Success snackbar variant - same black color
  static void showSuccess({
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    Get.snackbar(
      '',
      message,
      duration: duration,
      snackPosition: position,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      borderRadius: 12,
      borderWidth: 0,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      animationDuration: const Duration(milliseconds: 300),
      barBlur: 10,
      overlayBlur: 0,
      snackStyle: SnackStyle.FLOATING,
      titleText: const SizedBox.shrink(),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.center,
      ),
      shouldIconPulse: false,
      maxWidth: 400,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
    );
  }

  // Error snackbar variant - same black color
  static void showError({
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    Get.snackbar(
      '',
      message,
      duration: duration,
      snackPosition: position,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      borderRadius: 12,
      borderWidth: 0,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      animationDuration: const Duration(milliseconds: 300),
      barBlur: 10,
      overlayBlur: 0,
      snackStyle: SnackStyle.FLOATING,
      titleText: const SizedBox.shrink(),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.center,
      ),
      shouldIconPulse: false,
      maxWidth: 400,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
    );
  }

  // Warning snackbar variant - same black color
  static void showWarning({
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    Get.snackbar(
      '',
      message,
      duration: duration,
      snackPosition: position,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      borderRadius: 12,
      borderWidth: 0,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      animationDuration: const Duration(milliseconds: 300),
      barBlur: 10,
      overlayBlur: 0,
      snackStyle: SnackStyle.FLOATING,
      titleText: const SizedBox.shrink(),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.center,
      ),
      shouldIconPulse: false,
      maxWidth: 400,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
    );
  }
} 