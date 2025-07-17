import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../utils/app_text_field.dart';
import '../utils/app_phone_field.dart';
import '../utils/app_button.dart';
import '../utils/custom_snackbar.dart';
import '../utils/autotextsize.dart';
import '../controllers/auth_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController(text: '+91');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final AuthController _authController = Get.put(AuthController());

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(_onNameFocusChange);
    _emailFocus.addListener(_onEmailFocusChange);
    _phoneFocus.addListener(_onPhoneFocusChange);
    _passwordFocus.addListener(_onPasswordFocusChange);
    _confirmPasswordFocus.addListener(_onConfirmPasswordFocusChange);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _onNameFocusChange() {
    if (!_nameFocus.hasFocus) {
      _validateName(_nameController.text);
    }
  }

  void _onEmailFocusChange() {
    if (!_emailFocus.hasFocus) {
      _validateEmail(_emailController.text);
    }
  }

  void _onPhoneFocusChange() {
    if (!_phoneFocus.hasFocus) {
      _validatePhone(_phoneController.text);
    }
  }

  void _onPasswordFocusChange() {
    if (!_passwordFocus.hasFocus) {
      _validatePassword(_passwordController.text);
    }
  }

  void _onConfirmPasswordFocusChange() {
    if (!_confirmPasswordFocus.hasFocus) {
      _validateConfirmPassword(_confirmPasswordController.text);
    }
  }

  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameError = 'Name is required';
      } else if (value.length < 2) {
        _nameError = 'Name must be at least 2 characters';
      } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
        _nameError = 'Name can only contain letters and spaces';
      } else {
        _nameError = null;
      }
    });
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Email is required';
      } else if (!GetUtils.isEmail(value)) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePhone(String value) {
    final countryCode = _countryCodeController.text.trim();
    setState(() {
      if (value.isEmpty) {
        _phoneError = 'Phone number is required';
      } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
        _phoneError = 'Please enter a valid 10-digit phone number';
      } else if (!countryCode.startsWith('+')) {
        _phoneError = 'Country code must start with +';
      } else if (!RegExp(r'^\+\d{1,3}$').hasMatch(countryCode)) {
        _phoneError = 'Please enter a valid country code';
      } else {
        _phoneError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 8) {
        _passwordError = 'Password must be at least 8 characters';
      } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$').hasMatch(value)) {
        _passwordError = 'Password must contain uppercase, lowercase, number and special character';
      } else {
        _passwordError = null;
      }
      // Validate confirm password when password changes
      if (_confirmPasswordController.text.isNotEmpty) {
        _validateConfirmPassword(_confirmPasswordController.text);
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
      } else if (value != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  void _handleSignUp() {
    // Validate all fields
    _validateName(_nameController.text);
    _validateEmail(_emailController.text);
    _validatePhone(_phoneController.text);
    _validatePassword(_passwordController.text);
    _validateConfirmPassword(_confirmPasswordController.text);

    // Check if there are any errors
    if (_nameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _confirmPasswordError == null) {
      
      // Format phone number with country code
      final phone = '${_countryCodeController.text}${_phoneController.text}';
      
      // Call signup method from auth controller
      _authController.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: phone.replaceAll(' ', ''),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColorHex),
      resizeToAvoidBottomInset: false,
      body: 
         Column(
          children: [
            SizedBox(height: 50),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      // Welcome Text
                      MusaffaAutoSizeText.displayExtraLarge(
                        'Create Account With ReferMe',
                        maxLines: 2,
                        color: Color(AppConstants.primaryColorHex),
                        fontWeight: FontWeight.w700,
                      ),

                      const SizedBox(height: 8),

                      MusaffaAutoSizeText.headlineSmall(
                        maxLines: 2,
                        'Join ReferMe and unlock rewards!',
                        color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                      ),

                      const SizedBox(height: 32),

                      // Form Fields
                      AppTextField(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        controller: _nameController,
                        focusNode: _nameFocus,
                        errorText: _nameError,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icon(
                          CupertinoIcons.person,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onSubmitted: (_) {
                          _nameFocus.unfocus();
                          FocusScope.of(context).requestFocus(_emailFocus);
                        },
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        labelText: 'Email Address',
                        hintText: 'Enter your email',
                        controller: _emailController,
                        focusNode: _emailFocus,
                        errorText: _emailError,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icon(
                          CupertinoIcons.mail,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onSubmitted: (_) {
                          _emailFocus.unfocus();
                          FocusScope.of(context).requestFocus(_phoneFocus);
                        },
                      ),

                      const SizedBox(height: 16),

                      AppPhoneField(
                        controller: _phoneController,
                        countryCodeController: _countryCodeController,
                        focusNode: _phoneFocus,
                        errorText: _phoneError,
                        onSubmitted: (_) {
                          _phoneFocus.unfocus();
                          FocusScope.of(context).requestFocus(_passwordFocus);
                        },
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        labelText: 'Password',
                        hintText: 'Create a strong password',
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        errorText: _passwordError,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icon(
                          CupertinoIcons.lock,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        onSubmitted: (_) {
                          _passwordFocus.unfocus();
                          FocusScope.of(context).requestFocus(_confirmPasswordFocus);
                        },
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        errorText: _confirmPasswordError,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icon(
                          CupertinoIcons.lock,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        onSubmitted: (_) {
                          _confirmPasswordFocus.unfocus();
                          _handleSignUp();
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Section with Sign Up Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    text: 'Create Account',
                    onPressed: _handleSignUp,
                    isLoading: _authController.isLoading,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MusaffaAutoSizeText.headlineSmall(
                        'Already have an account? ',
                        color: Colors.grey.shade600,
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: MusaffaAutoSizeText.headlineSmall(
                          'Login',
                          fontWeight: FontWeight.w600,
                          color: Color(AppConstants.primaryColorHex),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 0),
                ],
              ),
            ),
          ],
        ),
      
    );
  }
} 