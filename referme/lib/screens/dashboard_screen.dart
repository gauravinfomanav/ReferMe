import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:referme/screens/all_contacts_screen.dart';
import '../constants/app_constants.dart';
import '../controllers/matched_contacts_controller.dart';
import '../controllers/contacts_controller.dart';
import '../controllers/referral_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/autotextsize.dart';
import 'referrals_screen.dart';
import 'referral_chat_screen.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MatchedContactsController contactsController = Get.put(MatchedContactsController());
    final ContactsController contactsUploadController = Get.put(ContactsController());

    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColorHex),
      body: SafeArea(
        child: Obx(() 
           {
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                     
                     
                      
                      await contactsController.fetchMatchedContacts();
                    },
                    child: const Text('Refresh Contacts'),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
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
                                  maxLines: 2,
                                  'Connect with your network and share reffrals to earn rewards.',
                                  color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                          // IconButton(
                          //   onPressed: () async {
                          //     // Refresh contacts: upload all contacts first, then fetch matched
                          //     await contactsUploadController.loadContacts();
                          //     await contactsUploadController.uploadContacts();
                          //     await contactsController.fetchMatchedContacts();
                          //   },
                          //   icon: Icon(
                          //     Icons.refresh,
                          //     color: Color(AppConstants.primaryColorHex),
                          //   ),
                          // ),
                        ],
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
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final contact = contactsData.unmatchedContacts[index];
                        return _buildContactCard(contact, isMatched: false, contactsController: contactsController);
                      },
                      childCount: contactsData.unmatchedContacts.length > 15 
                          ? 15 
                          : contactsData.unmatchedContacts.length,
                    ),
                  ),
                ),
                if (contactsData.unmatchedContacts.length > 15)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(AppConstants.primaryColorHex),
                              Color(AppConstants.primaryColorHex).withOpacity(0.8),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Get.to(() => AllContactsScreen(
                                contacts: contactsData.unmatchedContacts,
                                contactsController: contactsController,
                              ));
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'View All Contacts',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],

              // Bottom Paddingr
              const SliverToBoxAdapter(
                child: SizedBox(height: 48),
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
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Compact handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Compact header section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(AppConstants.primaryColorHex).withOpacity(0.03),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Compact avatar
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(AppConstants.primaryColorHex),
                                  Color(AppConstants.primaryColorHex).withOpacity(0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(AppConstants.primaryColorHex).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 24,
                              child: Text(
                                contactsController.getInitials(contact.name),
                                style: TextStyle(
                                  color: Color(AppConstants.primaryColorHex),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
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
                                  contact.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Color(AppConstants.primaryColorHex),
                                  ),
                                ),
                                if (contact.contactName != contact.name)
                                  Text(
                                    'Saved as: ${contact.contactName}',
                                    style: TextStyle(
                                      color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Compact cards section header
                            if (contact.hasCards && contact.cards.isNotEmpty) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.credit_card_rounded,
                                    color: Color(AppConstants.primaryColorHex),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Credit Cards',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Color(AppConstants.primaryColorHex),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${contact.cards.length}',
                                      style: TextStyle(
                                        color: Color(AppConstants.primaryColorHex),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Compact cards list
                              ...contact.cards.map((cardData) {
                                return _buildCompactCardItem(cardData, contact.userId);
                              }).toList(),
                            ] else ...[
                              // Compact no cards state
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Color(AppConstants.primaryColorHex).withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.credit_card_outlined,
                                      size: 32,
                                      color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No cards yet',
                                      style: TextStyle(
                                        color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'This user hasn\'t added any credit cards yet',
                                      style: TextStyle(
                                        color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
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

  Widget _buildCardItem(dynamic cardData) {
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
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.primaryColorHex),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Request Referral'),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCardItem(dynamic cardData) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(AppConstants.primaryColorHex).withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(AppConstants.primaryColorHex).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Card header with bank logo and info
            Row(
              children: [
                // Enhanced bank logo container
                Container(
                  width: 60,
                  height: 60,
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
                  child: FutureBuilder<String>(
                    future: _getBankLogo(bankName),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            snapshot.data!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Color(AppConstants.primaryColorHex).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.account_balance_rounded,
                                  color: Color(AppConstants.primaryColorHex),
                                  size: 28,
                                ),
                              );
                            },
                          ),
                        );
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: Color(AppConstants.primaryColorHex).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_rounded,
                          color: Color(AppConstants.primaryColorHex),
                          size: 28,
                        ),
                      );
                    },
                  ),
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
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bankName,
                        style: TextStyle(
                          color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Enhanced Request Referral button
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(AppConstants.primaryColorHex),
                    Color(AppConstants.primaryColorHex).withOpacity(0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(AppConstants.primaryColorHex).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // TODO: Implement referral request functionality
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Request Referral',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCardItem(dynamic cardData, String contactId) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(AppConstants.primaryColorHex).withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Color(AppConstants.primaryColorHex).withOpacity(0.08),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _buildBankLogo(snapshot.data!),
                  ),
                );
              }
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(AppConstants.primaryColorHex).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: Color(AppConstants.primaryColorHex),
                  size: 20,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardName,
                  style: TextStyle(
                    color: Color(AppConstants.primaryColorHex),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bankName,
                  style: TextStyle(
                    color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(AppConstants.primaryColorHex),
                  Color(AppConstants.primaryColorHex).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Color(AppConstants.primaryColorHex).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () => _requestReferral(cardData, contactId),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.share_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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


  Widget _buildBankLogo(String logoUrl) {
    if (logoUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        logoUrl,
        width: 40,
        height: 40,
        placeholderBuilder: (context) => _buildLoadingIndicator(),
        fit: BoxFit.contain,
      );
    } else {
      return Image.network(
        logoUrl,
        width: 40,
        height: 40,
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
      width: 40,
      height: 40,
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
      width: 40,
      height: 40,
      color: Colors.grey[200],
      child: Icon(
        Icons.account_balance,
        color: Color(AppConstants.primaryColorHex),
        size: 20,
      ),
    );
  }
