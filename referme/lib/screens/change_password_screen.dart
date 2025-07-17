import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_text_field.dart';
import '../utils/app_button.dart';
import '../utils/autotextsize.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  final FocusNode _currentPasswordFocus = FocusNode();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmNewPasswordFocus = FocusNode();

  final AuthController _authController = Get.find<AuthController>();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmNewPassword = true;

  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmNewPasswordError;

  @override
  void initState() {
    super.initState();
    _currentPasswordFocus.addListener(_onCurrentPasswordFocusChange);
    _newPasswordFocus.addListener(_onNewPasswordFocusChange);
    _confirmNewPasswordFocus.addListener(_onConfirmNewPasswordFocusChange);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();

    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmNewPasswordFocus.dispose();
    super.dispose();
  }

  void _onCurrentPasswordFocusChange() {
    if (!_currentPasswordFocus.hasFocus) {
      _validateCurrentPassword(_currentPasswordController.text);
    }
  }

  void _onNewPasswordFocusChange() {
    if (!_newPasswordFocus.hasFocus) {
      _validateNewPassword(_newPasswordController.text);
    }
  }

  void _onConfirmNewPasswordFocusChange() {
    if (!_confirmNewPasswordFocus.hasFocus) {
      _validateConfirmNewPassword(_confirmNewPasswordController.text);
    }
  }

  void _validateCurrentPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _currentPasswordError = 'Current password is required';
      } else {
        _currentPasswordError = null;
      }
    });
  }

  void _validateNewPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _newPasswordError = 'New password is required';
      } else if (value.length < 8) {
        _newPasswordError = 'Password must be at least 8 characters';
      } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$').hasMatch(value)) {
        _newPasswordError = 'Password must contain uppercase, lowercase, number and special character';
      } else if (value == _currentPasswordController.text) {
        _newPasswordError = 'New password must be different from current password';
      } else {
        _newPasswordError = null;
      }
      // Validate confirm password when new password changes
      if (_confirmNewPasswordController.text.isNotEmpty) {
        _validateConfirmNewPassword(_confirmNewPasswordController.text);
      }
    });
  }

  void _validateConfirmNewPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmNewPasswordError = 'Please confirm your new password';
      } else if (value != _newPasswordController.text) {
        _confirmNewPasswordError = 'Passwords do not match';
      } else {
        _confirmNewPasswordError = null;
      }
    });
  }

  Future<void> _handleChangePassword() async {
    // Validate all fields
    _validateCurrentPassword(_currentPasswordController.text);
    _validateNewPassword(_newPasswordController.text);
    _validateConfirmNewPassword(_confirmNewPasswordController.text);

    // Check if there are any errors
    if (_currentPasswordError == null &&
        _newPasswordError == null &&
        _confirmNewPasswordError == null) {
      
      final success = await _authController.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (success) {
        // Clear fields and pop screen
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColorHex),
      appBar: AppBar(
        title: MusaffaAutoSizeText.headlineMedium(
          'Change Password',
          color: Color(AppConstants.primaryColorHex),
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(AppConstants.primaryColorHex),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              
              MusaffaAutoSizeText.headlineSmall(
                'Update your password',
                color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                maxLines: 1,
              ),

              const SizedBox(height: 32),

              AppTextField(
                labelText: 'Current Password',
                hintText: 'Enter your current password',
                controller: _currentPasswordController,
                focusNode: _currentPasswordFocus,
                errorText: _currentPasswordError,
                obscureText: _obscureCurrentPassword,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  CupertinoIcons.lock,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                ),
                onSubmitted: (_) {
                  _currentPasswordFocus.unfocus();
                  FocusScope.of(context).requestFocus(_newPasswordFocus);
                },
              ),

              const SizedBox(height: 16),

              AppTextField(
                labelText: 'New Password',
                hintText: 'Create a strong password',
                controller: _newPasswordController,
                focusNode: _newPasswordFocus,
                errorText: _newPasswordError,
                obscureText: _obscureNewPassword,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  CupertinoIcons.lock,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
                onSubmitted: (_) {
                  _newPasswordFocus.unfocus();
                  FocusScope.of(context).requestFocus(_confirmNewPasswordFocus);
                },
              ),

              const SizedBox(height: 16),

              AppTextField(
                labelText: 'Confirm New Password',
                hintText: 'Re-enter your new password',
                controller: _confirmNewPasswordController,
                focusNode: _confirmNewPasswordFocus,
                errorText: _confirmNewPasswordError,
                obscureText: _obscureConfirmNewPassword,
                textInputAction: TextInputAction.done,
                prefixIcon: Icon(
                  CupertinoIcons.lock,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmNewPassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureConfirmNewPassword = !_obscureConfirmNewPassword),
                ),
                onSubmitted: (_) {
                  _confirmNewPasswordFocus.unfocus();
                  _handleChangePassword();
                },
              ),

              const SizedBox(height: 40),

              Obx(() => AppButton(
                text: 'Change Password',
                onPressed: _handleChangePassword,
                isLoading: _authController.isLoading,
              )),
            ],
          ),
        ),
      ),
    );
  }
} 