import 'package:get/get.dart';
import '../services/user_preferences_service.dart';
import '../controllers/matched_contacts_controller.dart';
import '../controllers/search_controller.dart' as search_controller;
import '../models/matched_contacts_model.dart';

class DashboardController extends GetxController {
  final MatchedContactsController _contactsController = Get.find<MatchedContactsController>();
  final search_controller.SearchController _searchController = Get.put(search_controller.SearchController());
  
  final RxString _preferredCard = ''.obs;
  final RxString _preferredCardBank = ''.obs;
  final RxBool _hasPreferredCard = false.obs;
  final RxBool _isSearching = false.obs;
  final RxBool _hasSearched = false.obs; // Flag to prevent multiple searches
  
  // Organized user lists
  final RxList<MatchedUser> _usersWithPreferredCard = <MatchedUser>[].obs;
  final RxList<MatchedUser> _usersWithOtherCards = <MatchedUser>[].obs;
  final RxList<UnmatchedContact> _contactsToInvite = <UnmatchedContact>[].obs;
  
  // Search results for preferred card (as Map objects from API)
  final RxList<Map<String, dynamic>> _preferredCardContacts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _preferredCardGlobalUsers = <Map<String, dynamic>>[].obs;

  String get preferredCard => _preferredCard.value;
  String get preferredCardBank => _preferredCardBank.value;
  bool get hasPreferredCard => _hasPreferredCard.value;
  bool get isSearching => _isSearching.value;
  bool get hasSearched => _hasSearched.value;
  
  List<MatchedUser> get usersWithPreferredCard => _usersWithPreferredCard;
  List<MatchedUser> get usersWithOtherCards => _usersWithOtherCards;
  List<UnmatchedContact> get contactsToInvite => _contactsToInvite;
  
  List<Map<String, dynamic>> get preferredCardContacts => _preferredCardContacts;
  List<Map<String, dynamic>> get preferredCardGlobalUsers => _preferredCardGlobalUsers;

  @override
  void onInit() {
    super.onInit();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await _loadUserPreferences();
    
    // Wait for contacts to be loaded, then organize users
    if (_contactsController.contactsData.value != null) {
      await organizeUsers();
    } else {
      // Listen for contacts data changes
      ever(_contactsController.contactsData, (contactsData) {
        if (contactsData != null && !_hasSearched.value) {
          organizeUsers();
        }
      });
    }
  }

  Future<void> _loadUserPreferences() async {
    final cardName = await UserPreferencesService.getPreferredCard();
    final bankName = await UserPreferencesService.getPreferredCardBank();
    
    _preferredCard.value = cardName ?? '';
    _preferredCardBank.value = bankName ?? '';
    _hasPreferredCard.value = cardName != null && cardName.isNotEmpty;
  }

  Future<void> organizeUsers() async {
    // Prevent multiple simultaneous calls
    if (_hasSearched.value) return;
    
    await _loadUserPreferences();
    
    final contactsData = _contactsController.contactsData.value;
    if (contactsData == null) return;

    // Mark as searched first to prevent multiple calls
    _hasSearched.value = true;

    // Clear previous lists
    _usersWithPreferredCard.clear();
    _usersWithOtherCards.clear();
    _contactsToInvite.clear();

    // If user has a preferred card, search for users with that card
    if (_hasPreferredCard.value && _preferredCard.value.isNotEmpty) {
      await _searchUsersWithPreferredCard();
    }

    // Organize matched users based on preferred card
    for (final user in contactsData.matchedUsers) {
      if (_hasPreferredCard.value && _hasUserPreferredCard(user)) {
        _usersWithPreferredCard.add(user);
      } else {
        _usersWithOtherCards.add(user);
      }
    }

    // Add unmatched contacts to invite list
    _contactsToInvite.addAll(contactsData.unmatchedContacts);
  }

  Future<void> _searchUsersWithPreferredCard() async {
    if (_preferredCard.value.isEmpty) return;
    
    // Only set searching to true if it's not already true to prevent flickering
    if (!_isSearching.value) {
      _isSearching.value = true;
    }
    
    try {
      await _searchController.searchUsers(
        query: _preferredCard.value,
        type: 'cardName',
        limit: 50,
      );
      
      // Get the search results
      _preferredCardContacts.assignAll(_searchController.contacts);
      _preferredCardGlobalUsers.assignAll(_searchController.globalUsers);
      
    } catch (e) {
      print('Error searching for users with preferred card: $e');
    } finally {
      _isSearching.value = false;
    }
  }

  bool _hasUserPreferredCard(MatchedUser user) {
    if (!_hasPreferredCard.value) return false;
    
    // Check if user has the preferred card in their cards list
    return user.cards.contains(_preferredCard.value) ||
           user.cards.contains(_preferredCardBank.value);
  }

  Future<void> refreshDashboard() async {
    await _contactsController.fetchMatchedContacts();
    await organizeUsers();
  }

  // Method to reset search state (call this when user changes preferences)
  Future<void> resetSearchState() async {
    _hasSearched.value = false;
    _preferredCardContacts.clear();
    _preferredCardGlobalUsers.clear();
    
    // Reload user preferences and reorganize users
    await _loadUserPreferences();
    await organizeUsers();
  }
} 