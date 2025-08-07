import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../controllers/card_selection_controller.dart';
import '../controllers/contacts_controller.dart';
import '../utils/autotextsize.dart';
import '../utils/app_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/card_preference_screen.dart';
import '../screens/main_screen.dart';

class SelectCardScreen extends StatefulWidget {
  final bool isFromProfile;
  
  const SelectCardScreen({
    super.key,
    this.isFromProfile = false,
  });

  @override
  State<SelectCardScreen> createState() => _SelectCardScreenState();
}

class _SelectCardScreenState extends State<SelectCardScreen> {
  final CardSelectionController _controller = Get.put(CardSelectionController());
  final ContactsController _contactsController = Get.put(ContactsController());
  
  // Add a flag to prevent multiple API calls
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Request contact permission when screen loads (only for signup flow)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isFromProfile) {
        print('🔄 Requesting contact permission...');
        _requestContactPermissionWithUI();
      } else {
        // Load user's existing cards when coming from profile
        _loadUserExistingCards();
      }
    });
  }

  // Load user's existing cards when coming from profile
  Future<void> _loadUserExistingCards() async {
    try {
      // Load the user's existing cards from the controller
      await _controller.loadBanks();
      
      // Load user's existing selected cards from SharedPreferences
      final savedCards = await CardSelectionController.getSavedCards();
      _controller.selectedCards.assignAll(savedCards);
      
      // If user has saved cards, select the first bank that has any of those cards
      if (savedCards.isNotEmpty) {
        for (final bank in _controller.banks) {
          if (bank.cards.any((card) => savedCards.contains(card))) {
            _controller.selectBank(bank.bank);
            break;
          }
        }
      }
      
    } catch (e) {
      print('Error loading user existing cards: $e');
    }
  }

  // Improved method to handle permission with better UI flow
  Future<void> _requestContactPermissionWithUI() async {
    try {
      // Show loading state while checking permission
      _contactsController.isLoading.value = true;
      
      // Check current permission status
      final status = await _contactsController.checkContactPermission();
      
      if (status == 'granted') {
        // Permission already granted, hide overlay and proceed
        _contactsController.permissionDenied.value = false;
        // Load contacts in background
        await _contactsController.loadContacts();
      } else {
        // Permission not granted, show permission UI
        _contactsController.permissionDenied.value = true;
      }
    } catch (e) {
      print('Error checking permission: $e');
      _contactsController.permissionDenied.value = true;
    } finally {
      _contactsController.isLoading.value = false;
    }
  }

  // Fixed method to handle permission request from UI
  Future<void> _handlePermissionRequest() async {
    try {
      _contactsController.isLoading.value = true;
      
      final result = await _contactsController.requestContactPermission();
      
      if (result == 'granted') {
        // Permission granted, hide overlay and load contacts
        _contactsController.permissionDenied.value = false;
        await _contactsController.loadContacts();
      } else {
        // Permission still denied, show explanation dialog and keep asking
        _contactsController.permissionDenied.value = true;
        _showPermissionNecessityDialog();
      }
    } catch (e) {
      print('Error requesting permission: $e');
      _contactsController.permissionDenied.value = true;
      _showPermissionNecessityDialog();
    } finally {
      _contactsController.isLoading.value = false;
    }
  }

  void _showPermissionNecessityDialog() {
    // Check if running on iOS
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      _showIOSPermissionInstructions();
    } else {
      _showGeneralPermissionDialog();
    }
  }

  void _showIOSPermissionInstructions() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.settings,
              color: Color(AppConstants.primaryColorHex),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Enable Contact Access',
                style: TextStyle(
                  color: Color(AppConstants.primaryColorHex),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To enable contact access on iOS, please follow these steps:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            _buildIOSStepItem(
              '1',
              'Open Settings',
              'Go to your iPhone\'s Settings app',
            ),
            const SizedBox(height: 12),
            _buildIOSStepItem(
              '2',
              'Find ReferMe',
              'Scroll down and tap on "ReferMe" in the app list',
            ),
            const SizedBox(height: 12),
            _buildIOSStepItem(
              '3',
              'Enable Contacts',
              'Toggle the "Contacts" switch to ON',
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(AppConstants.primaryColorHex),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'After enabling, return to the app and try again',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(AppConstants.primaryColorHex),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _handlePermissionRequest(); // Try again after user follows instructions
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.primaryColorHex),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _showGeneralPermissionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.people_outline,
              color: Color(AppConstants.primaryColorHex),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Contact Access Required',
                style: TextStyle(
                  color: Color(AppConstants.primaryColorHex),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We need access to your contacts to help you discover:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _buildBenefitItem(
              Icons.group_add,
              'Find Friends',
              'See how many of your contacts are already using ReferMe',
            ),
            const SizedBox(height: 12),
            _buildBenefitItem(
              Icons.credit_card,
              'Card Holders',
              'Discover which friends have credit cards for referral opportunities',
            ),
            const SizedBox(height: 12),
            _buildBenefitItem(
              Icons.monetization_on,
              'Earn Rewards',
              'Get referral bonuses when you successfully refer friends',
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Color(AppConstants.primaryColorHex),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your contacts are kept private and secure',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(AppConstants.primaryColorHex),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back(); // Close dialog
                _handlePermissionRequest(); // Ask for permission again
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppConstants.primaryColorHex),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Grant Permission',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false, // Prevent dismissing by tapping outside
    );
  }

  Widget _buildIOSStepItem(String step, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Color(AppConstants.primaryColorHex),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.primaryColorHex),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Color(AppConstants.primaryColorHex),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Fixed method to handle dashboard navigation with proper API calls and single loader
  Future<void> _handleDashboardNavigation() async {
    // Prevent multiple simultaneous calls
    if (_isNavigating) return;
    _isNavigating = true;

    // Show single loading indicator immediately
    _contactsController.isLoading.value = true;
    
    try {
      // Create list of futures for parallel execution
      List<Future> apiCalls = [];
      
      // 1. Always save selected cards
      apiCalls.add(_controller.saveCardSelectionStatus());
      
      if (widget.isFromProfile) {
        // If coming from profile, save cards and go to dashboard
        await _controller.saveCardSelectionStatus();
        Get.offAll(() => const MainScreen()); // Go to dashboard screen
      } else {
        // 2. Upload contacts only if permission is granted (for signup flow)
        if (!_contactsController.permissionDenied.value) {
          apiCalls.add(_contactsController.uploadContacts());
        }
        
        // Execute all API calls in parallel
        await Future.wait(apiCalls);
        
        // Navigate to card preference screen instead of main screen
        Get.off(() => const CardPreferenceScreen());
      }
      
    } catch (e) {
      print('Error during navigation: $e');
      // Show error message
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isNavigating = false;
      // Don't set loading to false here since we're navigating away
    }
  }

  // Method to skip contacts and proceed - REMOVED since permission is mandatory
  // void _skipContacts() {
  //   _contactsController.permissionDenied.value = false;
  //   _contactsController.isLoading.value = false;
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Allow back button press if coming from profile
      onWillPop: () async => widget.isFromProfile,
      child: Scaffold(
        backgroundColor: Color(AppConstants.backgroundColorHex),
        body: Obx(() {
          // Show loading overlay for any loading state
          if (_contactsController.isLoading.value) {
            return Container(
              color: Color(AppConstants.backgroundColorHex),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(AppConstants.primaryColorHex),
                      ),
                    ),
                    const SizedBox(height: 16),
                    MusaffaAutoSizeText.bodyLarge(
                      'Loading...',
                      color: Color(AppConstants.primaryColorHex),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Show permission overlay (only for signup flow)
          if (!widget.isFromProfile && _contactsController.permissionDenied.value) {
            return Container(
              color:  Color(AppConstants.backgroundColorHex),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contacts_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 24),
                  MusaffaAutoSizeText.headlineMedium(
                    'Contact Access Required',
                    color: Color(AppConstants.primaryColorHex),
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  MusaffaAutoSizeText.bodyLarge(
                    'We need access to your contacts to show you how many people use ReferMe and have credit cards, so you can ask them for referrals.',
                    color: Color(AppConstants.primaryColorHex),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                  
                  // Allow button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handlePermissionRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Give Permission',
                        style: TextStyle(
                          color: Color(AppConstants.primaryColorHex),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          
          // Main card selection UI
          return Scaffold(
            backgroundColor: Color(AppConstants.backgroundColorHex),
            appBar: AppBar(
              title: MusaffaAutoSizeText.headlineMedium(
                widget.isFromProfile ? 'Update Your Cards' : 'Select Your Credit Card',
                color: Color(AppConstants.primaryColorHex),
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: widget.isFromProfile,
            ),
            body: Column(
              children: [
                // Search Box
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        onChanged: _controller.searchCards,
                        decoration: InputDecoration(
                          hintText: 'Search banks or cards...',
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(AppConstants.primaryColorHex),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        if (_controller.selectedCards.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'Selected ${_controller.selectedCards.length} ${_controller.selectedCards.length == 1 ? 'card' : 'cards'}',
                              style: TextStyle(
                                color: Color(AppConstants.primaryColorHex),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),

                // Bank List
                Container(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.15),
                  child: Obx(() {
                    if (_controller.filteredBanks.isEmpty) {
                      return Center(
                        child: MusaffaAutoSizeText.bodyLarge(
                          'No banks found matching your search',
                          color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _controller.filteredBanks.length,
                      itemBuilder: (context, index) {
                        final bank = _controller.filteredBanks[index];
                        return Obx(() {
                          final isSelected = _controller.selectedBank.value == bank.bank;
                          return GestureDetector(
                            onTap: () => _controller.selectBank(bank.bank),
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? Color(AppConstants.primaryColorHex)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: _buildBankLogo(bank.logo),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Flexible(
                                    child: SizedBox(
                                      width: 80,
                                      child: MusaffaAutoSizeText.bodySmall(
                                        bank.bank,
                                        color: Color(AppConstants.primaryColorHex),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    );
                  }),
                ),

                // Card List
                Expanded(
                  child: Obx(() {
                    final cards = _controller.getSelectedBankCards();
                    final searchQuery = _controller.searchQuery.value.toLowerCase();
                    
                    if (_controller.selectedBank.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.credit_card_outlined,
                              size: 64,
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            MusaffaAutoSizeText.headlineSmall(
                              'Select a bank to view cards',
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: MusaffaAutoSizeText.bodyMedium(
                                'You can select multiple cards if you have more than one credit card',
                                color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (cards.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            MusaffaAutoSizeText.headlineSmall(
                              'No matching cards found',
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                              textAlign: TextAlign.center,
                            ),
                            if (searchQuery.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                                child: MusaffaAutoSizeText.bodyMedium(
                                  'Try a different search term or check the spelling',
                                  color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        final isMatching = searchQuery.isNotEmpty &&
                            card.toLowerCase().contains(searchQuery);
                            
                        return Obx(() {
                          final isSelected = _controller.selectedCards.contains(card);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _controller.toggleCardSelection(card),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Color(AppConstants.primaryColorHex)
                                          : Color(AppConstants.primaryColorHex).withOpacity(0.1),
                                    ),
                                    color: isMatching 
                                        ? Color(AppConstants.primaryColorHex).withOpacity(0.05)
                                        : Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            MusaffaAutoSizeText.headlineSmall(
                                              card,
                                              color: Color(AppConstants.primaryColorHex),
                                              maxLines: 1,
                                              fontWeight: isMatching ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                            if (isSelected)
                                              MusaffaAutoSizeText.bodySmall(
                                                'Tap to unselect',
                                                color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? Color(AppConstants.primaryColorHex)
                                                : Color(AppConstants.primaryColorHex).withOpacity(0.3),
                                            width: 2,
                                          ),
                                          color: isSelected
                                              ? Color(AppConstants.primaryColorHex)
                                              : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                      },
                    );
                  }),
                ),

                // Bottom Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Obx(() => AppButton(
                    text: _controller.selectedCards.isEmpty
                        ? 'Select at least one card'
                        : widget.isFromProfile
                            ? 'Update ${_controller.selectedCards.length} ${_controller.selectedCards.length == 1 ? 'card' : 'cards'}'
                            : 'Continue with ${_controller.selectedCards.length} ${_controller.selectedCards.length == 1 ? 'card' : 'cards'}',
                    onPressed: _controller.selectedCards.isEmpty
                        ? null
                        : _handleDashboardNavigation,
                  )),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBankLogo(String logoUrl) {
    if (logoUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        logoUrl,
        width: 50,
        height: 50,
        placeholderBuilder: (context) => _buildLoadingIndicator(),
        fit: BoxFit.contain,
      );
    } else {
      return Image.network(
        logoUrl,
        width: 50,
        height: 50,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingIndicator();
        },
      );
    }
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Color(AppConstants.primaryColorHex),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[200],
      child: Icon(
        Icons.credit_card,
        color: Color(AppConstants.primaryColorHex),
      ),
    );
  }
}