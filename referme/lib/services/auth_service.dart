import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final String baseUrl = AppConstants.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final url = '$baseUrl/api/auth/login';
    final body = {
      'identifier': identifier,
      'password': password,
    };

    print('\n🌐 Making login request to: $url');
    print('📤 Request body: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}\n');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('❌ Error during login: $e\n');
      return {
        'success': false,
        'message': 'An error occurred during login: $e',
      };
    }
  }

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = '$baseUrl/api/auth/signup';
    final body = {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    };

    print('\n🌐 Making signup request to: $url');
    print('📤 Request body: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}\n');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      print('❌ Error during signup: $e\n');
      return {
        'success': false,
        'message': 'An error occurred during signup: $e',
      };
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final url = '$baseUrl/api/auth/change-password';
    final body = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };

    print('\n🌐 Making change password request to: $url');
    print('📤 Request body: ${jsonEncode(body)}');

    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}\n');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      print('❌ Error during password change: $e\n');
      return {
        'success': false,
        'message': 'An error occurred while changing password: $e',
      };
    }
  }
} 