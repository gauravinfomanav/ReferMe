import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

enum AppButtonType {
  primary,   // Filled button with primary color
  secondary, // White button with border
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final bool disabled;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = type == AppButtonType.primary;
    final bool isDisabled = disabled || isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: 48, // Fixed height for consistency
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary 
              ? Color(AppConstants.primaryColorHex)
              : Colors.white,
          foregroundColor: isPrimary 
              ? Colors.white 
              : Color(AppConstants.primaryColorHex),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: !isPrimary ? BorderSide(
              color: Color(AppConstants.primaryColorHex).withOpacity(0.3),
              width: 1.5,
            ) : BorderSide.none,
          ),
          disabledBackgroundColor: isPrimary 
              ? Color(AppConstants.primaryColorHex).withOpacity(0.5)
              : Colors.grey.shade100,
          disabledForegroundColor: isPrimary 
              ? Colors.white.withOpacity(0.8)
              : Colors.grey.shade400,
        ),
        child: isLoading 
            ? _LoadingIndicator(isPrimary: isPrimary)
            : _ButtonContent(
                text: text,
                icon: icon,
                isPrimary: isPrimary,
              ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool isPrimary;

  const _ButtonContent({
    required this.text,
    required this.isPrimary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          fontFamily: AppConstants.newFontFamily,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: AppConstants.newFontFamily,
          ),
        ),
      ],
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  final bool isPrimary;

  const _LoadingIndicator({
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          isPrimary ? Colors.white : Color(AppConstants.primaryColorHex),
        ),
      ),
    );
  }
} 