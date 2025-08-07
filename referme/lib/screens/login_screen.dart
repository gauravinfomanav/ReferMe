import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:referme/screens/change_password_screen.dart';
import 'package:referme/screens/signup_screen.dart';
import '../constants/app_constants.dart';
import '../utils/app_text_field.dart';
import '../utils/app_button.dart';
import '../utils/custom_snackbar.dart';
import '../utils/autotextsize.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final AuthController _authController = Get.find<AuthController>();

  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Add focus listeners to validate on focus change
    _emailFocus.addListener(_onEmailFocusChange);
    _passwordFocus.addListener(_onPasswordFocusChange);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onEmailFocusChange() {
    if (!_emailFocus.hasFocus) {
      _validateEmail(_emailController.text);
    }
  }

  void _onPasswordFocusChange() {
    if (!_passwordFocus.hasFocus) {
      _validatePassword(_passwordController.text);
    }
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

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else {
        _passwordError = null;
      }
    });
  }

  void _handleLogin() {
    // Validate both fields
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);

    // Check if there are any errors
    if (_emailError == null && _passwordError == null) {
      _authController.login(
        identifier: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColorHex),
      resizeToAvoidBottomInset: false,
      body: Column(
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
                      'Welcome Back! 👋',
                      maxLines: 2,
                      color: Color(AppConstants.primaryColorHex),
                    ),

                    const SizedBox(height: 8),

                    MusaffaAutoSizeText.headlineSmall(
                      maxLines: 2,
                      'Sign in to continue your referral journey.',
                      color:
                          Color(AppConstants.primaryColorHex).withOpacity(0.7),
                    ),

                    const SizedBox(height: 40),

                    // Email Field
                    AppTextField(
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                      controller: _emailController,
                      focusNode: _emailFocus,
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      onSubmitted: (_) {
                        _emailFocus.unfocus();
                        FocusScope.of(context).requestFocus(_passwordFocus);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Password Field
                    AppTextField(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      errorText: _passwordError,
                       obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      onSubmitted: (_) {
                        _passwordFocus.unfocus();
                        _handleLogin();
                      },
                    ),

                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: TextButton(
                    //     onPressed: () {},
                    //     style: TextButton.styleFrom(
                    //       foregroundColor: Color(AppConstants.primaryColorHex),
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 12,
                    //         vertical: 8,
                    //       ),
                    //     ),
                    //     child: MusaffaAutoSizeText.headlineSmall(
                    //       'Forgot Password?',
                    //       color: Color(AppConstants.primaryColorHex),
                    //       fontWeight: FontWeight.w500,
                    //     ),
                    //   ),
                    // ),

                    const SizedBox(height: 40),

                    // Login Button
                    Obx(() => AppButton(
                          text: 'Login',
                          onPressed: _handleLogin,
                          isLoading: _authController.isLoading,
                        )),

                    const SizedBox(height: 24),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MusaffaAutoSizeText.headlineSmall(
                          'Don\'t have an account? ',
                          color: Colors.grey.shade600,
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const SignUpScreen());
                          },
                          child: MusaffaAutoSizeText.headlineSmall(
                            'Sign Up',
                            fontWeight: FontWeight.w600,
                            color: Color(AppConstants.primaryColorHex),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
