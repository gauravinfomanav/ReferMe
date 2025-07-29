import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../controllers/auth_controller.dart';

class ContactsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool permissionDenied = false.obs;
  List<Contact> allContacts = []; // Store loaded contacts

  // New method to check current permission status
  Future<String> checkContactPermission() async {
    try {
      print('🔍 Checking contact permission status...');
      final status = await FlutterContacts.requestPermission();
      return status ? 'granted' : 'denied';
    } catch (e) {
      print('❌ Error checking contact permission: $e');
      return 'denied';
    }
  }

  // Updated method to only request permission
  Future<String> requestContactPermission() async {
    try {
      print('👤 Starting contact permission request...');
      isLoading.value = true;
      final hasPermission = await FlutterContacts.requestPermission();
      
      if (hasPermission) {
        print('✅ Contact permission granted');
        permissionDenied.value = false;
      } else {
        print('❌ Contact permission denied');
        permissionDenied.value = true;
      }
      
      return hasPermission ? 'granted' : 'denied';
    } catch (e) {
      print('❌ Error requesting contact permission: $e');
      permissionDenied.value = true;
      return 'denied';
    } finally {
      isLoading.value = false;
    }
  }

  // New method to load contacts (separate from matching)
  Future<void> loadContacts() async {
    try {
      print('📱 Loading contacts...');
      // Get contacts
      allContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withAccounts: true,
      );

      print('📝 Found ${allContacts.length} contacts');
    } catch (e) {
      print('❌ Error loading contacts: $e');
    }
  }

  // Updated method to match contacts (now public)
  Future<void> uploadContacts() async {
    if (allContacts.isEmpty) {
      print('⚠️ No contacts to upload');
      return;
    }

    try {
      print('📤 Uploading contacts...');
      isLoading.value = true;

      // Format contacts for API and sanitize phone numbers
      final formattedContacts = allContacts.where((contact) => 
        contact.phones.isNotEmpty
      ).map((contact) => {
        "name": contact.displayName,
        "phone": _sanitizePhoneNumber(contact.phones.first.number),
      }).toList();

      print('📝 Formatted ${formattedContacts.length} valid contacts');

      // Get token from AuthController
      final authController = Get.find<AuthController>();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      print('🔑 Token status: ${token != null ? 'Found' : 'Not found'}');
      
      if (token == null) {
        print('❌ No token found in SharedPreferences');
        print('🔍 Checking if logged in: ${authController.isLoggedIn}');
        print('🔍 User ID: ${authController.userId}');
        return;
      }

      // Prepare request body
      final requestBody = {
        "contacts": formattedContacts,
      };

      // Log request details
      print('\n=== 📡 CONTACTS MATCH API REQUEST ===');
      print('URL: ${AppConstants.baseUrl}/api/contacts/match');
      print('Method: POST');
      print('Headers:');
      print('  Content-Type: application/json');
      print('  Authorization: Bearer ${token.substring(0, 20)}...');
      print('Request Body Sample (first 2 contacts):');
      print(jsonEncode({
        "contacts": formattedContacts.take(2).toList(),
      }));
      print('Total contacts being sent: ${formattedContacts.length}');
      print('================================\n');

      // Make API call
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/contacts/match'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      // Log response status
      print('\n=== 📡 CONTACTS MATCH API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body Length: ${response.body.length}');
      print('Response Body: ${response.body}'); // Log full response body for debugging
      print('==================================\n');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ Contacts matched successfully');
        } else {
          print('❌ API returned success: false - ${data['message']}');
        }
      } else {
        print('❌ Error matching contacts: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error uploading contacts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to sanitize phone numbers
  String _sanitizePhoneNumber(String phoneNumber) {
    // Remove all non-numeric characters (dashes, spaces, parentheses, etc.)
    return phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
  }
}