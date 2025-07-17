import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      appBar: AppBar(
        title: MusaffaAutoSizeText.headlineMedium(
          'My Network',
          color: Color(AppConstants.primaryColorHex),
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (contactsController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
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

        return RefreshIndicator(
          onRefresh: contactsController.fetchMatchedContacts,
          child: CustomScrollView(
            slivers: [
              // Matched Users Section
              if (contactsData.matchedUsers.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = contactsData.matchedUsers[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Color(AppConstants.primaryColorHex),
                              child: Text(
                                contactsController.getInitials(user.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MusaffaAutoSizeText.titleMedium(
                                  user.name,
                                  color: Color(AppConstants.primaryColorHex),
                                  fontWeight: FontWeight.w600,
                                ),
                                if (user.contactName != user.name)
                                  MusaffaAutoSizeText.bodySmall(
                                    'Saved as: ${user.contactName}',
                                    color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                                  ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    size: 16,
                                    color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  MusaffaAutoSizeText.bodySmall(
                                    user.hasCards
                                        ? '${user.cards.length} cards'
                                        : 'No cards yet',
                                    color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: contactsData.matchedUsers.length,
                  ),
                ),
              ],

              // Unmatched Contacts Section
              if (contactsData.unmatchedContacts.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final contact = contactsData.unmatchedContacts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                              child: Text(
                                contactsController.getInitials(contact.name),
                                style: TextStyle(
                                  color: Color(AppConstants.primaryColorHex),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            title: MusaffaAutoSizeText.titleMedium(
                              contact.name,
                              color: Color(AppConstants.primaryColorHex),
                              fontWeight: FontWeight.w600,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: MusaffaAutoSizeText.bodySmall(
                                contact.phone,
                                color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                              ),
                            ),
                            trailing: ElevatedButton.icon(
                              onPressed: () => contactsController.shareAppInvite(contact),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(AppConstants.primaryColorHex),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Invite'),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: contactsData.unmatchedContacts.length,
                  ),
                ),
              ],

              // Empty Space at Bottom
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        );
      }),
    );
  }
} 