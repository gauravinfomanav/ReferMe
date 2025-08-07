import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/custom_snackbar.dart';

class SearchController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString searchType = 'cardName'.obs; // 'cardName' or 'bankName'
  
  // Search results
  final RxList<Map<String, dynamic>> contacts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> globalUsers = <Map<String, dynamic>>[].obs;
  final RxInt totalContacts = 0.obs;
  final RxInt totalGlobalUsers = 0.obs;
  
  // Search history
  final RxList<String> searchHistory = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadSearchHistory();
  }
  
  Future<void> loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('search_history') ?? [];
      searchHistory.value = history;
    } catch (e) {
      print('Error loading search history: $e');
    }
  }
  
  Future<void> saveSearchHistory(String query) async {
    try {
      if (query.trim().isEmpty) return;
      
      // Remove if already exists and add to front
      searchHistory.remove(query.trim());
      searchHistory.insert(0, query.trim());
      
      // Keep only last 10 searches
      if (searchHistory.length > 10) {
        searchHistory.removeRange(10, searchHistory.length);
      }
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_history', searchHistory.toList());
    } catch (e) {
      print('Error saving search history: $e');
    }
  }
  
  Future<void> searchUsers({
    required String query,
    String type = 'cardName',
    int limit = 50,
  }) async {
    if (query.trim().isEmpty) {
      clearResults();
      return;
    }
    
    try {
      isSearching.value = true;
      searchQuery.value = query.trim();
      searchType.value = type;
      
      // Save to search history
      await saveSearchHistory(query.trim());
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) {
        CustomSnackBar.showError(message: 'Authentication required');
        return;
      }
      
      // Build query parameters
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      
      if (type == 'cardName') {
        queryParams['cardName'] = query.trim();
      } else {
        queryParams['bankName'] = query.trim();
      }
      
      final uri = Uri.parse('${AppConstants.baseUrl}/api/cards/search-users')
          .replace(queryParameters: queryParams);
      
      print('🔍 Searching users: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('📥 Search response status: ${response.statusCode}');
      print('📥 Search response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final responseData = data['data'];
          
          contacts.value = List<Map<String, dynamic>>.from(responseData['contacts'] ?? []);
          globalUsers.value = List<Map<String, dynamic>>.from(responseData['globalUsers'] ?? []);
          totalContacts.value = responseData['totalContacts'] ?? 0;
          totalGlobalUsers.value = responseData['totalGlobalUsers'] ?? 0;
          
          print('✅ Search completed: ${contacts.length} contacts, ${globalUsers.length} community users');
        } else {
          CustomSnackBar.showError(message: data['message'] ?? 'Search failed');
          clearResults();
        }
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        CustomSnackBar.showError(message: data['message'] ?? 'Please provide a valid search term');
        clearResults();
      } else if (response.statusCode == 401) {
        CustomSnackBar.showError(message: 'Authentication failed');
        clearResults();
      } else {
        // CustomSnackBar.showError(message: 'Search failed. Please try again.');
        clearResults();
      }
    } catch (e) {
      print('❌ Search error: $e');
      CustomSnackBar.showError(message: 'Network error. Please check your connection.');
      clearResults();
    } finally {
      isSearching.value = false;
    }
  }
  
  void clearResults() {
    contacts.clear();
    globalUsers.clear();
    totalContacts.value = 0;
    totalGlobalUsers.value = 0;
  }
  
  void clearSearch() {
    searchQuery.value = '';
    clearResults();
  }
  
  void removeFromHistory(String query) {
    searchHistory.remove(query);
    // Update SharedPreferences
    saveSearchHistory(''); // This will update the stored history
  }
  
  void clearHistory() {
    searchHistory.clear();
    // Clear from SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('search_history');
    });
  }
  
  bool get hasResults => contacts.isNotEmpty || globalUsers.isNotEmpty;
  bool get hasContacts => contacts.isNotEmpty;
  bool get hasGlobalUsers => globalUsers.isNotEmpty;
  
  // Method to check if a user is a community user
  bool isGlobalUser(String userId) {
    return globalUsers.any((user) => user['id'] == userId);
  }
} 