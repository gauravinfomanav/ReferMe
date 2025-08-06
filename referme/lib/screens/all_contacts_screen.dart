import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../controllers/matched_contacts_controller.dart';
import '../models/matched_contacts_model.dart';
import '../utils/autotextsize.dart';

class AllContactsScreen extends StatefulWidget {
  final List<UnmatchedContact> contacts;
  final MatchedContactsController contactsController;

  const AllContactsScreen({
    Key? key,
    required this.contacts,
    required this.contactsController,
  }) : super(key: key);

  @override
  State<AllContactsScreen> createState() => _AllContactsScreenState();
}

class _AllContactsScreenState extends State<AllContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RxList<UnmatchedContact> _filteredContacts = RxList<UnmatchedContact>([]);
  
  @override
  void initState() {
    super.initState();
    _filteredContacts.value = widget.contacts;
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      _filteredContacts.value = widget.contacts;
    } else {
      _filteredContacts.value = widget.contacts
          .where((contact) => 
              contact.name.toLowerCase().contains(query.toLowerCase()) ||
              contact.phone.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColorHex),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(AppConstants.primaryColorHex),
          ),
          onPressed: () => Get.back(),
        ),
        title: MusaffaAutoSizeText.titleLarge(
          'All Contacts',
          color: Color(AppConstants.primaryColorHex),
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterContacts,
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(AppConstants.primaryColorHex),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          
          // Contacts List
          Expanded(
            child: Obx(() {
              if (_filteredContacts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      MusaffaAutoSizeText.titleMedium(
                        'No contacts found',
                        color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  return _buildContactCard(
                    contact,
                    isMatched: false,
                    contactsController: widget.contactsController,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                        : 'Contact',
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

    return cardContent;
  }
} 