import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../controllers/search_controller.dart' as search_controller;
import '../controllers/referral_controller.dart';
import '../utils/autotextsize.dart';
import '../utils/app_text_field.dart';
import '../utils/app_button.dart';
import 'referral_chat_screen.dart';
import 'referrals_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final search_controller.SearchController _searchControllerInstance = Get.put(search_controller.SearchController());
  
  String _selectedSearchType = 'cardName';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce search to avoid too many API calls
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.trim().isNotEmpty) {
        _searchControllerInstance.searchUsers(
          query: _searchController.text,
          type: _selectedSearchType,
        );
      } else {
        _searchControllerInstance.clearResults();
      }
    });
  }

  void _performSearch() {
    if (_searchController.text.trim().isNotEmpty) {
      _searchControllerInstance.searchUsers(
        query: _searchController.text,
        type: _selectedSearchType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColorHex),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Search Bar and Filters
            _buildSearchSection(),
            
            // Results
            Expanded(
              child: Obx(() => _buildResults()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: MusaffaAutoSizeText.headlineMedium(
        'Search Cards',
        color: Color(AppConstants.primaryColorHex),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search Bar
          AppTextField(
            // labelText: 'Search',
            hintText: _selectedSearchType == 'cardName' ? 'Search by card name...' : 'Search by bank name...',
            controller: _searchController,
            focusNode: _searchFocus,
            textInputAction: TextInputAction.search,
            prefixIcon: Icon(
              CupertinoIcons.search,
              color: Colors.grey.shade400,
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      CupertinoIcons.clear,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _searchControllerInstance.clearSearch();
                    },
                  )
                : const SizedBox.shrink(),
            onSubmitted: (_) => _performSearch(),
          ),
          
          const SizedBox(height: 16),
          

          
          const SizedBox(height: 16),
          
          // Search Type Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSearchType = 'cardName';
                      });
                      if (_searchController.text.isNotEmpty) {
                        _performSearch();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedSearchType == 'cardName'
                            ? Color(AppConstants.primaryColorHex).withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: MusaffaAutoSizeText.bodyMedium(
                          'Card Name',
                          color: _selectedSearchType == 'cardName'
                              ? Color(AppConstants.primaryColorHex)
                              : Colors.grey.shade600,
                          fontWeight: _selectedSearchType == 'cardName'
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSearchType = 'bankName';
                      });
                      if (_searchController.text.isNotEmpty) {
                        _performSearch();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedSearchType == 'bankName'
                            ? Color(AppConstants.primaryColorHex).withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: MusaffaAutoSizeText.bodyMedium(
                          'Bank Name',
                          color: _selectedSearchType == 'bankName'
                              ? Color(AppConstants.primaryColorHex)
                              : Colors.grey.shade600,
                          fontWeight: _selectedSearchType == 'bankName'
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_searchControllerInstance.isSearching.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchController.text.isEmpty) {
      return _buildInitialState();
    }

    if (!_searchControllerInstance.hasResults) {
      return _buildEmptyState();
    }

    return _buildResultsList();
  }



  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.search,
            size: 64,
            color: Color(AppConstants.primaryColorHex).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          MusaffaAutoSizeText.headlineSmall(
            'Search for cards',
            color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
          ),
          const SizedBox(height: 8),
          MusaffaAutoSizeText.bodyMedium(
            'Find people with specific cards or banks',
            color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.search,
            size: 64,
            color: Color(AppConstants.primaryColorHex).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          MusaffaAutoSizeText.headlineSmall(
            'No search results found',
            color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
          ),
          const SizedBox(height: 8),
          MusaffaAutoSizeText.bodyMedium(
            'No results found for "${_searchController.text}" ${_selectedSearchType == 'cardName' ? 'cards' : 'banks'}',
            color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          MusaffaAutoSizeText.bodySmall(
            'Try searching with different keywords or check your spelling',
            color: Color(AppConstants.primaryColorHex).withOpacity(0.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Results Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(AppConstants.primaryColorHex).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.checkmark_circle,
                color: Color(AppConstants.primaryColorHex),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MusaffaAutoSizeText.bodyMedium(
                  'Found ${_searchControllerInstance.totalContacts.value} contacts and ${_searchControllerInstance.totalGlobalUsers.value} global users',
                  color: Color(AppConstants.primaryColorHex),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Contacts Section
        if (_searchControllerInstance.hasContacts) ...[
          _buildSectionHeader('Your Contacts', _searchControllerInstance.totalContacts.value),
          const SizedBox(height: 8),
          ..._searchControllerInstance.contacts.map((contact) => _buildUserCard(contact, true)),
          const SizedBox(height: 16),
        ],
        
        // Global Users Section
        if (_searchControllerInstance.hasGlobalUsers) ...[
          _buildSectionHeader('Global Users', _searchControllerInstance.totalGlobalUsers.value),
          const SizedBox(height: 8),
          ..._searchControllerInstance.globalUsers.map((user) => _buildUserCard(user, false)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        MusaffaAutoSizeText.titleMedium(
          title,
          color: Color(AppConstants.primaryColorHex),
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: MusaffaAutoSizeText.bodySmall(
            count.toString(),
            color: Color(AppConstants.primaryColorHex),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isContact) {
    final cards = List<Map<String, dynamic>>.from(user['cards'] ?? []);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
                    leading: CircleAvatar(
          backgroundColor: Color(AppConstants.primaryColorHex).withOpacity(0.1),
          child: Text(
            _getInitials(user['name'] ?? ''),
            style: TextStyle(
              color: Color(AppConstants.primaryColorHex),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
                    title: MusaffaAutoSizeText.bodyMedium(
          isContact ? (user['name'] ?? 'Unknown') : _maskName(user['name'] ?? ''),
          color: Color(AppConstants.primaryColorHex),
          fontWeight: FontWeight.w600,
        ),
            subtitle: null,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isContact
                    ? Color(AppConstants.primaryColorHex).withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: MusaffaAutoSizeText.bodySmall(
                isContact ? 'Contact' : 'Global User',
                color: isContact
                    ? Color(AppConstants.primaryColorHex)
                    : Colors.orange.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              // Navigate to chat or profile screen
              // You can implement this based on your app's navigation
              print('Tapped on user: ${user['name']}');
            },
          ),
          
          // Cards Section
          if (cards.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color(AppConstants.primaryColorHex).withOpacity(0.02),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MusaffaAutoSizeText.bodySmall(
                    'Available Cards:',
                    color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  ...cards.map((card) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.creditcard,
                              size: 16,
                              color: Color(AppConstants.primaryColorHex),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MusaffaAutoSizeText.bodyMedium(
                                    card['cardName'] ?? 'Unknown',
                                    color: Color(AppConstants.primaryColorHex),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  MusaffaAutoSizeText.bodySmall(
                                    card['bankName'] ?? 'Unknown',
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _requestReferral(card, user['id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(AppConstants.primaryColorHex),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: MusaffaAutoSizeText.bodySmall(
                              'Ask for Referral',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _maskName(String name) {
    if (name.isEmpty) return '*****';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      // For names with multiple words like "Gaurav Malode"
      final firstName = parts[0];
      final lastName = parts[1];
      
      String maskedFirstName = '';
      if (firstName.length <= 3) {
        maskedFirstName = firstName;
      } else {
        maskedFirstName = '${firstName.substring(0, 3)}***';
      }
      
      String maskedLastName = '';
      if (lastName.length <= 3) {
        maskedLastName = '***${lastName}';
      } else {
        maskedLastName = '***${lastName.substring(lastName.length - 3)}';
      }
      
      return '$maskedFirstName $maskedLastName';
    } else {
      // For single word names like "Gaurav"
      if (name.length <= 3) {
        return name;
      } else {
        return '${name.substring(0, 3)}***';
      }
    }
  }

  void _requestReferral(dynamic cardData, String targetUserId) async {
    // Extract bankName and cardName from the card object
    String bankName = '';
    String cardName = '';

    if (cardData is Map) {
      bankName = cardData['bankName']?.toString() ?? '';
      cardName = cardData['cardName']?.toString() ?? '';
    } else if (cardData is String) {
      // Use regex to extract bankName and cardName more reliably
      RegExp bankNameRegex = RegExp(r'bankName:\s*([^,}]+)');
      RegExp cardNameRegex = RegExp(r'cardName:\s*([^,}]+)');

      Match? bankMatch = bankNameRegex.firstMatch(cardData);
      Match? cardMatch = cardNameRegex.firstMatch(cardData);

      if (bankMatch != null) {
        bankName = bankMatch.group(1)?.trim() ?? '';
      }

      if (cardMatch != null) {
        cardName = cardMatch.group(1)?.trim() ?? '';
      }
    }

    // Get the referral controller
    final referralController = Get.put(ReferralController());
    
    // Show a dialog to confirm the referral request
    final confirmed = await showDialog<bool>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Request Referral',
          style: TextStyle(
            color: Color(AppConstants.primaryColorHex),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to request a referral for $cardName from $bankName?',
          style: TextStyle(
            color: Color(AppConstants.primaryColorHex).withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                print("Cancel button tapped");
                Navigator.of(context).pop(false);
              },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                print("Request button tapped");
                Navigator.of(context).pop(true);
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.primaryColorHex),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Request',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        );
      },
    );

    if (confirmed == true) {
      // Send the referral request
      final success = await referralController.requestReferral(
        targetUserId,
        bankName,
        cardName,
      );

      if (success) {
        // Get the created referral and navigate to chat screen
        await referralController.fetchReferrals();
        
        // Find the newly created referral
        final newReferral = referralController.sentReferrals.firstWhereOrNull(
          (referral) => referral.targetUserId == targetUserId && 
                       referral.message.contains(cardName)
        );
        
        if (newReferral != null) {
          // Navigate to chat screen with the new referral
          Get.to(() => ReferralChatScreen(
            referral: newReferral,
            isFromReceivedTab: false,
          ));
        } else {
          // Fallback to referrals screen if chat not found
        Get.to(() => const ReferralsScreen());
        }
      }
    }
  }
} 