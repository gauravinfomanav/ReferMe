import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/custom_snackbar.dart';

class ProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) {
        CustomSnackBar.show(message: 'No authentication token found');
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          userData.value = data['data']['user'];
        } else {
          CustomSnackBar.show(message : data['message'] ?? 'Failed to fetch profile');
        }
      } else {
        CustomSnackBar.show(message: 'Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      CustomSnackBar.show(message: 'Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String getInitials(String name) {
    if (name.isEmpty) return '';
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    try {
      final seconds = timestamp['_seconds'] as int;
      final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
} 