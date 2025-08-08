import 'package:get/get.dart';
import '../services/user_preferences_service.dart';
import '../controllers/matched_contacts_controller.dart';
import '../controllers/search_controller.dart' as search_controller;
import '../controllers/preference_controller.dart';
import '../models/matched_contacts_model.dart';

class DashboardController extends GetxController {
  final MatchedContactsController _contactsController = Get.find<MatchedContactsController>();
  final search_controller.SearchController _searchController = Get.put(search_controller.SearchController());
  final PreferenceController _preferenceController = Get.put(PreferenceController());
  
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
    print('🔄 DEBUG: Loading user preferences');
    
    // Check preference status first
    await _preferenceController.checkPreferenceStatus();
    
    if (_preferenceController.hasPreferences.value) {
      print('✅ DEBUG: User has API preferences');
      // Get preferences from API
      await _preferenceController.getPreferences();
      
      final cardName = _preferenceController.getPreferredCardName();
      final bankName = _preferenceController.getPreferredBankName();
      
      _preferredCard.value = cardName ?? '';
      _preferredCardBank.value = bankName ?? '';
      _hasPreferredCard.value = cardName != null && cardName.isNotEmpty;
      
      print('🔍 DEBUG: Loaded from API - Card: $cardName, Bank: $bankName');
    } else {
      print('⚠️ DEBUG: No API preferences, using local fallback');
      // Fallback to local preferences if no API preferences
      final cardName = await UserPreferencesService.getPreferredCard();
      final bankName = await UserPreferencesService.getPreferredCardBank();
      
      _preferredCard.value = cardName ?? '';
      _preferredCardBank.value = bankName ?? '';
      _hasPreferredCard.value = cardName != null && cardName.isNotEmpty;
      
      print('🔍 DEBUG: Loaded from local - Card: $cardName, Bank: $bankName');
    }
    
    print('✅ DEBUG: Preferences loaded - Has preferred card: ${_hasPreferredCard.value}');
  }

  Future<void> organizeUsers() async {
    print('🔄 DEBUG: Organizing users');
    
    // Prevent multiple simultaneous calls
    if (_hasSearched.value) {
      print('⚠️ DEBUG: Already searched, skipping organization');
      return;
    }
    
    await _loadUserPreferences();
    
    final contactsData = _contactsController.contactsData.value;
    if (contactsData == null) {
      print('⚠️ DEBUG: No contacts data available');
      return;
    }

    // Mark as searched first to prevent multiple calls
    _hasSearched.value = true;

    // Clear previous lists
    _usersWithPreferredCard.clear();
    _usersWithOtherCards.clear();
    _contactsToInvite.clear();

    // If user has a preferred card, search for users with that card
    if (_hasPreferredCard.value && _preferredCard.value.isNotEmpty) {
      print('🔍 DEBUG: Searching for users with preferred card: ${_preferredCard.value}');
      await _searchUsersWithPreferredCard();
    } else {
      print('⚠️ DEBUG: No preferred card to search for');
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
    
    print('✅ DEBUG: User organization completed');
    print('📊 DEBUG: Users with preferred card: ${_usersWithPreferredCard.length}');
    print('📊 DEBUG: Users with other cards: ${_usersWithOtherCards.length}');
    print('📊 DEBUG: Contacts to invite: ${_contactsToInvite.length}');
  }

  Future<void> _searchUsersWithPreferredCard() async {
    if (_preferredCard.value.isEmpty) {
      print('⚠️ DEBUG: No preferred card to search for');
      return;
    }
    
    print('🔍 DEBUG: Searching for users with card: ${_preferredCard.value}');
    
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
      
      print('✅ DEBUG: Search completed');
      print('📊 DEBUG: Found ${_preferredCardContacts.length} contacts with preferred card');
      print('📊 DEBUG: Found ${_preferredCardGlobalUsers.length} global users with preferred card');
      
    } catch (e) {
      print('❌ DEBUG: Error searching for users with preferred card: $e');
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
    print('🔄 DEBUG: Resetting dashboard search state');
    
    _hasSearched.value = false;
    _preferredCardContacts.clear();
    _preferredCardGlobalUsers.clear();
    
    // Force refresh preferences from API
    await _preferenceController.checkPreferenceStatus();
    if (_preferenceController.hasPreferences.value) {
      await _preferenceController.getPreferences();
    }
    
    // Reload user preferences and reorganize users
    await _loadUserPreferences();
    await organizeUsers();
    
    print('✅ DEBUG: Dashboard search state reset completed');
    print('🔍 DEBUG: Current preferred card: ${_preferredCard.value}');
    print('🔍 DEBUG: Current preferred bank: ${_preferredCardBank.value}');
  }
} 