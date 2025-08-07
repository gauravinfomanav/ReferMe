import 'dart:convert';
import 'package:get/get.dart';
import 'package:referme/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../screens/select_card_screen.dart';
import '../utils/custom_snackbar.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  
  final AuthService _authService = AuthService();
  final _isLoading = false.obs;
  final _isLoggedIn = false.obs;
  final _userId = RxString('');
  
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  String get userId => _userId.value;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final userData = prefs.getString(AppConstants.userDataKey);
    
    if (token != null && userData != null) {
      final user = jsonDecode(userData);
      _userId.value = user['id'];
      _isLoggedIn.value = true;
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> userData, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.userDataKey, jsonEncode(userData));
    
    _userId.value = userData['id'];
    _isLoggedIn.value = true;
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    try {
      _isLoading.value = true;
      
      final response = await _authService.login(
        identifier: identifier,
        password: password,
      );
      
      if (response['success']) {
        final userData = response['data']['user'];
        final token = response['data']['token'];
        
        await _saveUserData(userData, token);
        
        CustomSnackBar.showSuccess(
          message: response['message'] ?? 'Login successful!',
        );
        
        Get.off(() => const MainScreen());
      } else {
        CustomSnackBar.showError(
          message: response['message'] ?? 'Login failed',
        );
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
     
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      _isLoading.value = true;
      
      final response = await _authService.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      
      if (response['success']) {
        final userData = response['data']['user'];
        final token = response['data']['token'];
        
        await _saveUserData(userData, token);
        
        CustomSnackBar.showSuccess(
          message: response['message'] ?? 'Account created successfully!',
        );
        
        // Navigate to card preference screen instead of card selection screen
        Get.off(() => const SelectCardScreen());
      } else {
        // Handle API error response
        CustomSnackBar.showError(
          message: response['message'] ?? 'Failed to create account',
        );
        // Explicitly throw an error to ensure finally block executes
        throw Exception(response['message'] ?? 'Failed to create account');
      }
    } catch (e) {
      // This will catch both network errors and the explicit error we threw above
      
    } finally {
      // This should always execute
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userDataKey);
    _isLoggedIn.value = false;
    _userId.value = '';
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;
      
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      if (response['success']) {
        CustomSnackBar.showSuccess(
          message: response['message'] ?? 'Password changed successfully',
        );
        return true;
      } else {
        CustomSnackBar.showError(
          message: response['message'] ?? 'Failed to change password',
        );
        return false;
      }
    } catch (e) {
      CustomSnackBar.showError(
        message: 'An error occurred while changing password',
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
} 