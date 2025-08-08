import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../controllers/card_selection_controller.dart';
import '../controllers/search_controller.dart' as search_controller;
import '../controllers/preference_controller.dart';
import '../screens/main_screen.dart';
import '../utils/autotextsize.dart';
import '../utils/app_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/custom_snackbar.dart';
import '../controllers/dashboard_controller.dart';

class CardPreferenceScreen extends StatefulWidget {
  final bool isFromProfile;
  
  const CardPreferenceScreen({
    super.key,
    this.isFromProfile = false,
  });

  @override
  State<CardPreferenceScreen> createState() => _CardPreferenceScreenState();
}

class _CardPreferenceScreenState extends State<CardPreferenceScreen> {
  final CardSelectionController _controller = Get.put(CardSelectionController());
  final search_controller.SearchController _searchController = Get.put(search_controller.SearchController());
  final PreferenceController _preferenceController = Get.put(PreferenceController());
  
  bool _isSearching = false;
  final RxString _selectedCardName = ''.obs;
  
  // Results from search
  int _totalContacts = 0;
  int _totalGlobalUsers = 0;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() {
      // _isLoading = true; // Removed unused field
    });

    try {
      await _controller.loadBanks();
    } catch (e) {
      CustomSnackBar.showError(message: 'Failed to load cards');
    } finally {
      setState(() {
        // _isLoading = false; // Removed unused field
      });
    }
  }

  Future<void> _searchUsersForCard() async {
    if (_selectedCardName.value.isEmpty) {
      CustomSnackBar.showError(message: 'Please select a card first');
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // First, save the user's preference
      final preferenceData = [
        {
          'bankName': _controller.selectedBank.value,
          'cardName': _selectedCardName.value,
          'priority': 10,
          'isActive': true,
        }
      ];
      
      final preferenceResponse = await _preferenceController.addPreferences(preferenceData);
      
      if (!preferenceResponse.success) {
        // If preference already exists (409), that's okay - continue
        if (preferenceResponse.statusCode != 409) {
          CustomSnackBar.showError(message: 'Failed to save preference');
          return;
        }
      }
      
      // Then search for users
      await _searchController.searchUsers(
        query: _selectedCardName.value,
        type: 'cardName',
        limit: 50,
      );
      
      _totalContacts = _searchController.totalContacts.value;
      _totalGlobalUsers = _searchController.totalGlobalUsers.value;
      
      // Show results and navigate to main screen
      _showResultsAndNavigate();
      
    } catch (e) {
      CustomSnackBar.showError(message: 'Failed to search users');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _showResultsAndNavigate() {
    final totalUsers = _totalContacts + _totalGlobalUsers;
    
    // Determine the message based on results
    String message;
    String title;
    
    if (_totalContacts > 0 && _totalGlobalUsers > 0) {
      title = 'Great! Found Users';
      message = 'You have $_totalContacts contacts and $_totalGlobalUsers community users who have this card.';
    } else if (_totalContacts > 0) {
      title = 'Found Contacts!';
      message = '$_totalContacts of your contacts have this card. You can ask them for referrals.';
    } else if (_totalGlobalUsers > 0) {
      title = 'Found Community Users!';
      message = '$_totalGlobalUsers community users have this card. You can request referrals from them.';
    } else {
      title = 'No Users Found';
      message = 'No users found with this card yet. Don\'t worry! You can explore the dashboard to discover other cards or invite your contacts who might have this card.';
    }
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              _totalContacts > 0 || _totalGlobalUsers > 0 
                  ? Icons.check_circle_rounded 
                  : Icons.info_outline_rounded,
              color: _totalContacts > 0 || _totalGlobalUsers > 0 
                  ? const Color(0xFF4CAF50) 
                  : Color(AppConstants.primaryColorHex),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
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
              message,
              style: TextStyle(
                color: Color(AppConstants.primaryColorHex).withOpacity(0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (_totalContacts > 0 || _totalGlobalUsers > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(AppConstants.primaryColorHex).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    if (_totalContacts > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people_rounded,
                                color: Color(AppConstants.primaryColorHex),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'From Contacts',
                                style: TextStyle(
                                  color: Color(AppConstants.primaryColorHex),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$_totalContacts',
                            style: TextStyle(
                              color: Color(AppConstants.primaryColorHex),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (_totalGlobalUsers > 0) const SizedBox(height: 8),
                    ],
                    if (_totalGlobalUsers > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.public_rounded,
                                color: Color(AppConstants.primaryColorHex),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Community Users',
                                style: TextStyle(
                                  color: Color(AppConstants.primaryColorHex),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$_totalGlobalUsers',
                            style: TextStyle(
                              color: Color(AppConstants.primaryColorHex),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_totalContacts > 0 && _totalGlobalUsers > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(AppConstants.primaryColorHex),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Total: $totalUsers users',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You can now request referrals from these users or explore other cards.',
                style: TextStyle(
                  color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'The app is growing every day! You can explore other cards in the dashboard or invite friends who might have this card.',
                style: TextStyle(
                  color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Explore Other Cards',
              style: TextStyle(
                color: Color(AppConstants.primaryColorHex),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              
              if (widget.isFromProfile) {
                // If coming from profile, update the existing preference instead of creating new one
                final firstPreference = _preferenceController.getFirstActivePreference();
                if (firstPreference != null) {
                  final updateData = {
                    'bankName': _controller.selectedBank.value,
                    'cardName': _selectedCardName.value,
                    'priority': 10,
                    'isActive': true,
                  };
                  
                  final updateResponse = await _preferenceController.updatePreference(
                    firstPreference['id'],
                    updateData,
                  );
                  
                  if (updateResponse.success) {
                    // Force refresh preferences in memory
                    await _preferenceController.forceRefresh();
                    
                    // Add a small delay to ensure API update is processed
                    await Future.delayed(const Duration(milliseconds: 500));
                    
                    // Reset dashboard state and navigate to main screen
                    final dashboardController = Get.find<DashboardController>();
                    await dashboardController.resetSearchState();
                    Get.offAll(() => const MainScreen());
                  } else {
                    CustomSnackBar.showError(message: 'Failed to update preference');
                  }
                } else {
                  // No existing preference found, create new one
                  final preferenceData = [
                    {
                      'bankName': _controller.selectedBank.value,
                      'cardName': _selectedCardName.value,
                      'priority': 10,
                      'isActive': true,
                    }
                  ];
                  
                  final addResponse = await _preferenceController.addPreferences(preferenceData);
                  
                  if (addResponse.success) {
                    // Force refresh preferences in memory
                    await _preferenceController.forceRefresh();
                    
                    // Add a small delay to ensure API update is processed
                    await Future.delayed(const Duration(milliseconds: 500));
                    
                    // Reset dashboard state and navigate to main screen
                    final dashboardController = Get.find<DashboardController>();
                    await dashboardController.resetSearchState();
                    Get.offAll(() => const MainScreen());
                  } else {
                    CustomSnackBar.showError(message: 'Failed to save preference');
                  }
                }
              } else {
                // Show setting up account loader before navigating (for signup flow)
                Get.dialog(
                  WillPopScope(
                    onWillPop: () async => false,
                    child: AlertDialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      content: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(AppConstants.primaryColorHex),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Setting up your account...',
                              style: TextStyle(
                                color: Color(AppConstants.primaryColorHex),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  barrierDismissible: false,
                );
                
                // Navigate after a short delay to show the loader
                Future.delayed(const Duration(milliseconds: 1500), () {
                  Get.off(() => const MainScreen());
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.primaryColorHex),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue to App',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColorHex),
      appBar: AppBar(
        title: MusaffaAutoSizeText.headlineMedium(
          'What card are you looking for?',
          color: Color(AppConstants.primaryColorHex),
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                  if (_selectedCardName.value.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Selected card: $_selectedCardName',
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
                      onTap: () {
                        _controller.selectBank(bank.bank);
                        // Remove auto-selection of first card
                        // _selectedCardName.value = bank.cards.isNotEmpty ? bank.cards.first : '';
                      },
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
            child: _isSearching
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(AppConstants.primaryColorHex),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Searching for users...',
                          style: TextStyle(
                            color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Obx(() {
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
                                'Select the card you want to get a referral for',
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
                          final isSelected = _selectedCardName.value == card;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  _selectedCardName.value = card;
                                },
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
            
              text: _selectedCardName.value.isEmpty
                  ? 'Select a card to find users'
                  : 'Find Users with ${_selectedCardName.value}',
              onPressed: _selectedCardName.value.isEmpty
                  ? null
                  : _searchUsersForCard,
              isLoading: _isSearching,
            )),
          ),
        ],
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