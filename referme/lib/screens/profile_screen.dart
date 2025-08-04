import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/card_selection_controller.dart';
import '../screens/login_screen.dart';
import '../utils/autotextsize.dart';
import '../utils/custom_snackbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, String>> _getCardBankMapping() async {
    try {
      final String jsonString =
          await rootBundle.loadString('lib/utils/card_list.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      Map<String, String> cardBankMap = {};
      for (var bank in jsonList) {
        String bankName = bank['bank'] ?? '';
        List<dynamic> cards = bank['cards'] ?? [];
        for (var card in cards) {
          cardBankMap[card] = bankName;
        }
      }
      return cardBankMap;
    } catch (e) {
      print('Error loading card bank mapping: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    final ProfileController profileController = Get.put(ProfileController());
    final CardSelectionController cardController =
        Get.put(CardSelectionController());

    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColorHex),
      body: SafeArea(
        child: Obx(() {
          if (profileController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final userData = profileController.userData.value;
          if (userData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.person_crop_circle_badge_exclam,
                    size: 64,
                    color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  MusaffaAutoSizeText.headlineSmall(
                    'Failed to load profile',
                    color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => profileController.fetchUserProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Profile Avatar
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(AppConstants.primaryColorHex),
                                Color(AppConstants.primaryColorHex)
                                    .withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              profileController
                                  .getInitials(userData['name'] ?? ''),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        MusaffaAutoSizeText.headlineMedium(
                          userData['name'] ?? 'N/A',
                          color: Color(AppConstants.primaryColorHex),
                          fontWeight: FontWeight.w700,
                        ),
                        const SizedBox(height: 8),
                        MusaffaAutoSizeText.bodyLarge(
                          userData['email'] ?? 'N/A',
                          color: Color(AppConstants.primaryColorHex)
                              .withOpacity(0.7),
                        ),
                        const SizedBox(height: 4),
                        MusaffaAutoSizeText.bodyLarge(
                          userData['phone'] ?? 'N/A',
                          color: Color(AppConstants.primaryColorHex)
                              .withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Account Details
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MusaffaAutoSizeText.titleMedium(
                          'Account Details',
                          color: Color(AppConstants.primaryColorHex),
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                            'Member Since',
                            profileController
                                .formatDate(userData['createdAt'])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Selected Cards Section
                  FutureBuilder<List<String>>(
                    future: CardSelectionController.getSavedCards(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return FutureBuilder<Map<String, String>>(
                          future: _getCardBankMapping(),
                          builder: (context, bankMappingSnapshot) {
                            return Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.creditcard,
                                            color: Color(
                                                AppConstants.primaryColorHex),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          MusaffaAutoSizeText.titleMedium(
                                            'Your Cards (${snapshot.data!.length})',
                                            color: Color(
                                                AppConstants.primaryColorHex),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ...snapshot.data!.map((cardName) {
                                        String bankName = bankMappingSnapshot
                                                .data?[cardName] ??
                                            'Unknown Bank';
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .checkmark_circle_fill,
                                                color: Color(AppConstants
                                                    .primaryColorHex),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '$cardName ($bankName)',
                                                  style: TextStyle(
                                                    color: Color(AppConstants
                                                        .primaryColorHex),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  // Options
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildProfileOption(
                          icon: CupertinoIcons.person,
                          title: 'Edit Profile',
                          onTap: () {
                            CustomSnackBar.show(message: 'Coming Soon!');
                          },
                        ),
                        const Divider(),
                        _buildProfileOption(
                          icon: CupertinoIcons.creditcard,
                          title: 'Add More Cards',
                          onTap: () {
                            CustomSnackBar.show(message: 'Coming Soon!');
                          },
                        ),
                        const Divider(),
                        _buildProfileOption(
                          icon: CupertinoIcons.lock,
                          title: 'Change Password',
                          onTap: () {
                            CustomSnackBar.show(message: 'Coming Soon!');
                          },
                        ),
                        const Divider(),
                        _buildProfileOption(
                          icon: CupertinoIcons.bell,
                          title: 'Notifications',
                          onTap: () {
                            CustomSnackBar.show(message: 'Coming Soon!');
                          },
                        ),
                        const Divider(),
                        _buildProfileOption(
                          icon: CupertinoIcons.question_circle,
                          title: 'Help & Support',
                          onTap: () {
                            CustomSnackBar.show(message: 'Coming Soon!');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: () {
                        _showCustomLogoutDialog(context, () {
                          authController.logout();
                          Get.offAll(() => const LoginScreen());
                        });
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Color(AppConstants.primaryColorHex),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Color(AppConstants.primaryColorHex),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MusaffaAutoSizeText.titleMedium(
                title,
                color: Color(AppConstants.primaryColorHex),
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              CupertinoIcons.forward,
              color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

void _showCustomLogoutDialog(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                ),
                child: Icon(
                  CupertinoIcons.square_arrow_right,
                  size: 28,
                  color: Color(AppConstants.primaryColorHex),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.primaryColorHex),
                  fontFamily: AppConstants.newFontFamily,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                  fontFamily: AppConstants.newFontFamily,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(AppConstants.primaryColorHex),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppConstants.newFontFamily,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color: Color(AppConstants.primaryColorHex),
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppConstants.newFontFamily,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

