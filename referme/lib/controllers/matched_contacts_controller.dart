import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/matched_contacts_model.dart';
import '../constants/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../controllers/auth_controller.dart';

class MatchedContactsController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<MatchedContactsData?> contactsData = Rx<MatchedContactsData?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchMatchedContacts();
  }

  Future<void> fetchMatchedContacts() async {
    try {
      isLoading.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) {
        CustomSnackBar.showError(message: 'Authentication token not found');
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/contacts/matched-users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = MatchedContactsResponse.fromJson(jsonDecode(response.body));
        if (data.success) {
          contactsData.value = data.data;
        } else {
          CustomSnackBar.showError(message: data.message);
        }
      } else {
        CustomSnackBar.showError(message: 'Failed to fetch contacts');
      }
    } catch (e) {
      CustomSnackBar.showError(message: 'Error fetching contacts: $e');
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