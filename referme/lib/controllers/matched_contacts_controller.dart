import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/matched_contacts_model.dart';
import '../constants/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../controllers/auth_controller.dart';
import '../controllers/contacts_controller.dart';

class MatchedContactsController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<MatchedContactsData?> contactsData = Rx<MatchedContactsData?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeContacts();
  }

  Future<void> _initializeContacts() async {
    try {
      isLoading.value = true;
      
      // Check if we have permission first
      final contactsController = Get.put(ContactsController());
      final permissionStatus = await contactsController.checkContactPermission();
      
      if (permissionStatus != 'granted') {
        print('Contact permission not granted, skipping contact initialization');
        return;
      }
      
      // Load contacts with error handling
      try {
      await contactsController.loadContacts();
      } catch (e) {
        print('Error loading contacts: $e');
        return;
      }
      
      // Upload contacts with error handling
      try {
      await contactsController.uploadContacts();
      } catch (e) {
        print('Error uploading contacts: $e');
        // Continue to fetch matched contacts even if upload fails
      }
      
      // Fetch matched contacts with error handling
      try {
      await fetchMatchedContacts();
      } catch (e) {
        print('Error fetching matched contacts: $e');
      }
    } catch (e) {
      print('Error initializing contacts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMatchedContacts() async {
    try {
      isLoading.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) {
        print('Authentication token not found');
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/contacts/matched-users?limit=2000'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30)); // Add timeout

      if (response.statusCode == 200) {
        try {
        final data = MatchedContactsResponse.fromJson(jsonDecode(response.body));
        if (data.success) {
          contactsData.value = data.data;
        } else {
            print('API returned error: ${data.message}');
          }
        } catch (jsonError) {
          print('Error parsing response: $jsonError');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching contacts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> shareAppInvite(UnmatchedContact contact) async {
    try {
      final message = '''
Hey ${contact.name}! 👋

Join me on ReferMe and let's earn rewards together! 🎁

Download the app now: https://referme.app/invite

My referral code: ${Get.find<AuthController>().userId}
''';

      await Share.share(
        message,
        subject: 'Join me on ReferMe!',
      );
    } catch (e) {
      CustomSnackBar.showError(message: 'Failed to share invite: $e');
    }
  }

  String getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
} 