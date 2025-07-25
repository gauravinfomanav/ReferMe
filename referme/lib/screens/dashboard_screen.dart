import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../controllers/matched_contacts_controller.dart';
import '../utils/autotextsize.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MatchedContactsController contactsController = Get.put(MatchedContactsController());

    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColorHex),
      body: SafeArea(
        child: Obx(() {
          if (contactsController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final contactsData = contactsController.contactsData.value;
          if (contactsData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 64,
                    color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  MusaffaAutoSizeText.headlineSmall(
                    'No contacts found',
                    color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MusaffaAutoSizeText.headlineSmall(
                        'My Network',
                        color: Color(AppConstants.primaryColorHex),
                        fontWeight: FontWeight.w600,
                        
                      ),
                      const SizedBox(height: 8),
                      MusaffaAutoSizeText.bodyLarge(
                        'Connect and share with your network',
                        color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(AppConstants.primaryColorHex),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'ReferMe Users',
                          contactsData.matchedUsers.length.toString(),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        _buildStatItem(
                          'Potential Users',
                          contactsData.unmatchedContacts.length.toString(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Matched Users Section
              if (contactsData.matchedUsers.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Color(AppConstants.primaryColorHex),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        MusaffaAutoSizeText.titleMedium(
                          'ReferMe Users',
                          color: Color(AppConstants.primaryColorHex),
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final user = contactsData.matchedUsers[index];
                        return _buildContactCard(user, isMatched: true, contactsController: contactsController);
                      },
                      childCount: contactsData.matchedUsers.length,
                    ),
                  ),
                ),
              ],

              // Unmatched Contacts Section
              if (contactsData.unmatchedContacts.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_add_rounded,
                          color: Color(AppConstants.primaryColorHex),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        MusaffaAutoSizeText.titleMedium(
                          'Invite to ReferMe',
                          color: Color(AppConstants.primaryColorHex),
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final contact = contactsData.unmatchedContacts[index];
                        return _buildContactCard(contact, isMatched: false, contactsController: contactsController);
                      },
                      childCount: contactsData.unmatchedContacts.length,
                    ),
                  ),
                ),
              ],

              // Bottom Paddingr
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        MusaffaAutoSizeText.headlineMedium(
          value,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        MusaffaAutoSizeText.bodyMedium(
          label,
          color: Colors.white.withOpacity(0.8),
        ),
      ],
    );
  }

  Widget _buildContactCard(dynamic contact, {required bool isMatched, required MatchedContactsController contactsController}) {
    final cardContent = Card(
      elevation: 2,
      shadowColor: Color(AppConstants.primaryColorHex).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Avatar Section
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(AppConstants.primaryColorHex),
                    Color(AppConstants.primaryColorHex).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(AppConstants.primaryColorHex).withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(1.5),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: Text(
                  contactsController.getInitials(contact.name),
                  style: TextStyle(
                    color: Color(AppConstants.primaryColorHex),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name and Status Row
                  Row(
                    children: [
                      Expanded(
                        child: MusaffaAutoSizeText.titleMedium(
                          contact.name,
                          color: Color(AppConstants.primaryColorHex),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isMatched)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(AppConstants.primaryColorHex).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.credit_card,
                                size: 12,
                                color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                contact.hasCards ? '${contact.cards.length}' : '0',
                                style: TextStyle(
                                  color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Subtitle (Contact Info or Saved Name)
                  Text(
                    isMatched
                        ? (contact.contactName != contact.name
                            ? 'Saved as ${contact.contactName}'
                            : 'ReferMe User')
                        : contact.phone,
                    style: TextStyle(
                      color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Action Button
            if (!isMatched) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => contactsController.shareAppInvite(contact),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(AppConstants.primaryColorHex),
                        Color(AppConstants.primaryColorHex).withOpacity(0.7),
                        const Color(0xFF4F8CFF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(AppConstants.primaryColorHex).withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.ios_share_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Invite',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Icon(
                Icons.arrow_forward_ios,
                color: Color(AppConstants.primaryColorHex).withOpacity(0.3),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );

    // If matched user, wrap with GestureDetector to show bottom sheet
    if (isMatched) {
      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: Get.context!,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with avatar and user info
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(AppConstants.primaryColorHex),
                                        Color(AppConstants.primaryColorHex).withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 32,
                                    child: Text(
                                      contactsController.getInitials(contact.name),
                                      style: TextStyle(
                                        color: Color(AppConstants.primaryColorHex),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        contact.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 22,
                                          color: Color(AppConstants.primaryColorHex),
                                        ),
                                      ),
                                      if (contact.contactName != contact.name)
                                        Text(
                                          'Saved as: ${contact.contactName}',
                                          style: TextStyle(
                                            color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                                            fontSize: 14,
                                          ),
                                        ),
                                      if (contact.phone != null && contact.phone.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              size: 16,
                                              color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              contact.phone,
                                              style: TextStyle(
                                                color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Cards section
                            if (contact.hasCards && contact.cards.isNotEmpty) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    color: Color(AppConstants.primaryColorHex),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Credit Cards',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Color(AppConstants.primaryColorHex),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${contact.cards.length} ${contact.cards.length == 1 ? 'card' : 'cards'}',
                                      style: TextStyle(
                                        color: Color(AppConstants.primaryColorHex),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Cards list
                              ...contact.cards.map((cardData) {
                                // Debug the actual structure
                                print('🔍 cardData type: ${cardData.runtimeType}');
                                print('🔍 cardData: $cardData');
                                
                                // Extract bankName and cardName from the card object
                                String bankName = '';
                                String cardName = '';
                                
                                if (cardData is Map) {
                                  print('🔍 cardData is Map, keys: ${cardData.keys}');
                                  bankName = cardData['bankName']?.toString() ?? '';
                                  cardName = cardData['cardName']?.toString() ?? '';
                                  print('🔍 Extracted from Map - bankName: "$bankName", cardName: "$cardName"');
                                } else if (cardData is String) {
                                  // Parse the string to extract bankName and cardName
                                  String dataStr = cardData.toString();
                                  print('🔍 Parsing string: $dataStr');
                                  
                                  // Use regex to extract bankName and cardName more reliably
                                  RegExp bankNameRegex = RegExp(r'bankName:\s*([^,}]+)');
                                  RegExp cardNameRegex = RegExp(r'cardName:\s*([^,}]+)');
                                  
                                  Match? bankMatch = bankNameRegex.firstMatch(dataStr);
                                  Match? cardMatch = cardNameRegex.firstMatch(dataStr);
                                  
                                  if (bankMatch != null) {
                                    bankName = bankMatch.group(1)?.trim() ?? '';
                                  }
                                  
                                  if (cardMatch != null) {
                                    cardName = cardMatch.group(1)?.trim() ?? '';
                                  }
                                  
                                  print('🔍 Extracted from string - bankName: "$bankName", cardName: "$cardName"');
                                } else {
                                  print('🔍 cardData is NOT a Map or String');
                                }
                                
                                print('🔍 Final Bank: $bankName, Card: $cardName');
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Bank logo
                                      FutureBuilder<String>(
                                        future: _getBankLogo(bankName),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                            return Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  snapshot.data!,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                                                      child: Icon(
                                                        Icons.account_balance,
                                                        color: Color(AppConstants.primaryColorHex),
                                                        size: 24,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.account_balance,
                                              color: Color(AppConstants.primaryColorHex),
                                              size: 24,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cardName,
                                              style: TextStyle(
                                                color: Color(AppConstants.primaryColorHex),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              bankName,
                                              style: TextStyle(
                                                color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Color(AppConstants.primaryColorHex).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.credit_card_outlined,
                                      size: 48,
                                      color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No cards yet',
                                      style: TextStyle(
                                        color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'This user hasn\'t added any credit cards yet',
                                      style: TextStyle(
                                        color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: cardContent,
      );
    }
    return cardContent;
  }

  Future<String> _getBankLogo(String bankName) async {
    try {
      print('🔍 Looking for bank logo: $bankName');
      if (bankName.isEmpty) {
        print('❌ Bank name is empty');
        return '';
      }
      
      final banks = await _loadBankData();
      print('🔍 Loaded ${banks.length} banks from JSON');
      
      for (var bank in banks) {
        final currentBankName = bank['bank']?.toString() ?? '';
        print('🔍 Checking bank: "$currentBankName" against "$bankName"');
        
        if (currentBankName == bankName) {
          final logo = bank['logo'] ?? '';
          print('✅ Found bank logo for $bankName: $logo');
          return logo;
        }
      }
      print('❌ No bank logo found for: $bankName');
      return '';
    } catch (e) {
      print('❌ Error getting bank logo: $e');
      return '';
    }
  }

  Future<List<Map<String, dynamic>>> _loadBankData() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/utils/card_list.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading bank data: $e');
      return [];
    }
  }
} 