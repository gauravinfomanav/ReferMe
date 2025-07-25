import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/http_method.dart';
import '../utils/api_response.dart';

class ApiService {
  static const String _baseUrl = AppConstants.baseUrl;
  
  /// Main API call function
  static Future<ApiResponse> call({
    required HttpMethod method,
    required List<String> path,
    Map<String, dynamic>? params,
    Map<String, dynamic>? body,
    dynamic logParams,
  }) async {
    try {
      // Build URL
      final url = _buildUrl(path, params);
      
      // Get headers
      final headers = await _getHeaders();
      
      // Log request in debug mode
      if (kDebugMode) {
        _logRequest(method, url, body, logParams);
      }
      
      // Make HTTP request
      http.Response response;
      
      switch (method) {
        case HttpMethod.get:
          response = await http.get(Uri.parse(url), headers: headers);
          break;
        case HttpMethod.post:
          response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case HttpMethod.put:
          response = await http.put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case HttpMethod.delete:
          response = await http.delete(Uri.parse(url), headers: headers);
          break;
        case HttpMethod.patch:
          response = await http.patch(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
      }
      
      // Log response in debug mode
      if (kDebugMode) {
        _logResponse(response);
      }
      
      // Handle response
      return _handleResponse(response);
      
    } catch (e) {
      if (kDebugMode) {
        print('API Error: $e');
      }
      
      return ApiResponse.error(
        message: 'Network error occurred',
        exceptionMessage: e.toString(),
      );
    }
  }
  
  /// Build URL from path segments and query parameters
  static String _buildUrl(List<String> path, Map<String, dynamic>? params) {
    final pathString = path.join('/');
    String url = '$_baseUrl/$pathString';

    if (kDebugMode) {
      print('We Called This URL: $url');
    }
    
    if (params != null && params.isNotEmpty) {
      final queryParams = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      url += '?$queryParams';
    }
    
    return url;
  }
  
  /// Get headers with authorization token
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    
    final headers = {
      'Content-Type': 'application/json',
    };
    
    // Add authorization header if token exists
    if (token != null && token.isNotEmpty) {
      headers[AppConstants.authorizationHeader] = 'Bearer $token';
    }
    
    return headers;
  }
  
  /// Handle HTTP response and return ApiResponse
  static ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;
    
    try {
      final jsonData = body.isNotEmpty ? jsonDecode(body) : null;
      
      switch (statusCode) {
        case 200:
        case 201:
          return ApiResponse.success(
            message: jsonData?['message'],
            data: jsonData?['data'] ?? jsonData,
            statusCode: statusCode,
          );
          
        case 401:
          // Handle unauthorized - trigger logout
          _handleUnauthorized();
          return ApiResponse.error(
            message: 'Unauthorized access. Please login again.',
            statusCode: statusCode,
          );
          
        case 422:
          // Handle validation errors
          final errors = jsonData?['errors'] ?? jsonData?['message'];
          return ApiResponse.error(
            message: errors is String ? errors : 'Validation error occurred',
            statusCode: statusCode,
          );
          
        case 409:
          return ApiResponse.error(
            message: jsonData?['message'] ?? 'Conflict occurred',
            statusCode: statusCode,
          );
          
        case 400:
          return ApiResponse.error(
            message: jsonData?['message'] ?? 'Bad request',
            statusCode: statusCode,
          );
          
        case 403:
          return ApiResponse.error(
            message: jsonData?['message'] ?? 'Forbidden',
            statusCode: statusCode,
          );
          
        case 404:
          return ApiResponse.error(
            message: jsonData?['message'] ?? 'Resource not found',
            statusCode: statusCode,
          );
          
        case 500:
          return ApiResponse.error(
            message: jsonData?['message'] ?? 'Internal server error',
            statusCode: statusCode,
          );
          
        default:
          return ApiResponse.error(
            message: jsonData?['message'] ?? 'Unexpected error occurred',
            statusCode: statusCode,
          );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to parse response',
        exceptionMessage: e.toString(),
        statusCode: statusCode,
      );
    }
  }
  
  /// Handle unauthorized access by clearing stored data
  static Future<void> _handleUnauthorized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error handling unauthorized: $e');
      }
    }
  }
  
  /// Log request details in debug mode
  static void _logRequest(HttpMethod method, String url, Map<String, dynamic>? body, dynamic logParams) {
    print('🌐 API Request:');
    print('Method: ${method.value}');
    print('URL: $url');
    if (body != null) {
      print('Body: ${jsonEncode(body)}');
    }
    if (logParams != null) {
      print('Log Params: $logParams');
    }
    print('---');
  }
  
  /// Log response details in debug mode
  static void _logResponse(http.Response response) {
    print('📡 API Response:');
    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');
    print('---');
  }
  
  /// Save token to shared preferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }
  
  /// Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }
  
  /// Clear stored token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }

  final String baseUrl = AppConstants.baseUrl;

  Future<ApiResponse> post(String endpoint, Map<String, dynamic> body) async {
    try {
      // Retrieve token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      final headers = {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      print("*******we made a req to $endpoint with body $body and headers $headers");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          data: jsonDecode(response.body),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          message: 'Request failed',
          exceptionMessage: 'Status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Request failed',
        exceptionMessage: e.toString(),
      );
    }
  }
} 