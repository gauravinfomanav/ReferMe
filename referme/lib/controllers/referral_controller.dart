import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/referral_model.dart';
import '../constants/app_constants.dart';
import '../utils/custom_snackbar.dart';

class ReferralController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isChatLoading = false.obs;
  final RxList<Referral> sentReferrals = <Referral>[].obs;
  final RxList<Referral> receivedReferrals = <Referral>[].obs;
  final Rx<Referral?> currentReferral = Rx<Referral?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchReferrals();
  }

  Future<void> fetchReferrals() async {
    try {
      isLoading.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) {
        CustomSnackBar.showError(message: 'Authentication token not found');
        return;
      }

      // Fetch sent referrals
      final sentResponse = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/referrals?type=sent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Fetch received referrals
      final receivedResponse = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/referrals?type=received'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    
      if (sentResponse.statusCode == 200) {
        final sentData = ReferralResponse.fromJson(jsonDecode(sentResponse.body));
        if (sentData.success && sentData.data?.referrals != null) {
          sentReferrals.value = sentData.data!.referrals!;
        }
      }

      if (receivedResponse.statusCode == 200) {
        final receivedData = ReferralResponse.fromJson(jsonDecode(receivedResponse.body));
        if (receivedData.success && receivedData.data?.referrals != null) {
          receivedReferrals.value = receivedData.data!.referrals!;
        }
      }
    } catch (e) {
      CustomSnackBar.showError(message: 'Error fetching referrals: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> requestReferral(String targetUserId, String bankName, String cardName) async {
    try {
      isLoading.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) {
        CustomSnackBar.showError(message: 'Authentication token not found');
        return false;
      }

      final message = "Hey! I want a referral for $cardName from $bankName. Can you please help me with a referral link?";

      final request = ReferralRequest(
        targetUserId: targetUserId,
        message: message,
      );

      print("***********Request body: ${jsonEncode(request.toJson())}");
      print("***********Target User ID: $targetUserId");
      print("***********Message: $message");

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/referrals/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );
      print("***********called this url ${AppConstants.baseUrl}/api/referrals/request");
      print("***********response: ${response.body}");
      if (response.statusCode == 201) {
        final data = ReferralResponse.fromJson(jsonDecode(response.body));
        if (data.success) {
          CustomSnackBar.showSuccess(message: 'Referral request sent successfully!');
          await fetchReferrals(); // Refresh the list
          return true;
        } else {
          CustomSnackBar.showError(message: data.message);
          return false;
        }
      } else if (response.statusCode == 409) {
        CustomSnackBar.showError(message: 'Referral request already exists');
        return false;
      } else {
        final errorData = jsonDecode(response.body);
        CustomSnackBar.showError(message: errorData['message'] ?? 'Failed to send referral request');
        return false;
      }
    } catch (e) {
      CustomSnackBar.showError(message: 'Error sending referral request: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> sendReferralLink(String referralId, String link) async {
    try {
      isLoading.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) {
        CustomSnackBar.showError(message: 'Authentication token not found');
        return false;
      }

      final message = "Hey! Here's your referral link. You can use this to apply for the card.";

      final referralMessage = ReferralMessage(
        message: message,
        link: link,
      );

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/referrals/$referralId/message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(referralMessage.toJson()),
      );

      if (response.statusCode == 201) {
        final data = ReferralResponse.fromJson(jsonDecode(response.body));
        if (data.success) {
          CustomSnackBar.showSuccess(message: 'Referral link sent successfully!');
          await fetchReferrals(); // Refresh the list
          return true;
        } else {
          CustomSnackBar.showError(message: data.message);
          return false;
        }
      } else if (response.statusCode == 409) {
        CustomSnackBar.showError(message: 'Referral link already sent');
        return false;
      } else {
        final errorData = jsonDecode(response.body);
        CustomSnackBar.showError(message: errorData['message'] ?? 'Failed to send referral link');
        return false;
      }
    } catch (e) {
      CustomSnackBar.showError(message: 'Error sending referral link: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Referral?> getReferralDetails(String referralId) async {
    try {
      isChatLoading.value = true;
      currentReferral.value = null; // Clear previous chat data
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) {
        CustomSnackBar.showError(message: 'Authentication token not found');
        return null;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/referrals/$referralId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = ReferralResponse.fromJson(jsonDecode(response.body));
        if (data.success && data.data?.referral != null) {
          currentReferral.value = data.data!.referral;
          update(); // Notify GetBuilder to rebuild
          return data.data!.referral;
        } else {
          CustomSnackBar.showError(message: data.message);
          return null;
        }
      } else {
        final errorData = jsonDecode(response.body);
        CustomSnackBar.showError(message: errorData['message'] ?? 'Failed to get referral details');
        return null;
      }
    } catch (e) {
      CustomSnackBar.showError(message: 'Error getting referral details: $e');
      return null;
    } finally {
      isChatLoading.value = false;
    }
  }

  String getReferralStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      case 'expired':
        return 'Expired';
      default:
        return 'Unknown';
    }
  }

  Color getReferralStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA500); // Orange
      case 'completed':
        return const Color(0xFF4CAF50); // Green
      case 'rejected':
        return const Color(0xFFF44336); // Red
      case 'expired':
        return const Color(0xFF9E9E9E); // Grey
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 