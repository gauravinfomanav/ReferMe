import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utils/http_method.dart';
import '../utils/api_response.dart';
import '../constants/app_constants.dart';

class PreferenceController extends GetxController {
  final RxList<Map<String, dynamic>> preferences = <Map<String, dynamic>>[].obs;
  final RxBool hasPreferences = false.obs;
  final RxInt totalCount = 0.obs;
  final RxInt activeCount = 0.obs;
  final RxString lastUpdated = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🚀 DEBUG: PreferenceController initialized');
  }

  /// Add user preferences
  Future<ApiResponse> addPreferences(List<Map<String, dynamic>> preferencesList) async {
    print('🔵 DEBUG: Calling API - POST ${AppConstants.baseUrl}/api/preferences');
    
    final requestBody = {
      'preferences': preferencesList,
    };
    
    print('🔵 DEBUG: Request Body: ${requestBody.toString()}');
    
    try {
      final response = await ApiService.call(
        method: HttpMethod.post,
        path: ['api', 'preferences'],
        body: requestBody,
        logParams: 'Adding preferences',
      );
      
      print('🟢 DEBUG: Response Status Code: ${response.statusCode}');
      print('🟢 DEBUG: Response Body: ${response.data}');
      
      if (response.success) {
        print('✅ DEBUG: Preferences added successfully');
        print('✅ DEBUG: Message: ${response.message}');
        
        // Refresh preferences list
        await getPreferences();
      } else {
        print('🔴 DEBUG: Failed to add preferences');
        print('🔴 DEBUG: Error: ${response.message}');
      }
      
      return response;
    } catch (e) {
      print('🔴 DEBUG: Exception while adding preferences: $e');
      return ApiResponse.error(message: 'Failed to add preferences');
    }
  }

  /// Get user's preferences
  Future<ApiResponse> getPreferences({
    bool? isActive,
    String sortBy = 'priority',
    String sortOrder = 'desc',
  }) async {
    print('🔵 DEBUG: Calling API - GET ${AppConstants.baseUrl}/api/preferences');
    
    final params = <String, dynamic>{
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
    
    if (isActive != null) {
      params['isActive'] = isActive.toString();
    }
    
    print('🔵 DEBUG: Query Parameters: $params');
    
    try {
      final response = await ApiService.call(
        method: HttpMethod.get,
        path: ['api', 'preferences'],
        params: params,
        logParams: 'Getting preferences',
      );
      
      print('🟢 DEBUG: Response Status Code: ${response.statusCode}');
      print('🟢 DEBUG: Response Body: ${response.data}');
      
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final preferencesList = data['preferences'] as List<dynamic>;
        
        preferences.value = preferencesList.cast<Map<String, dynamic>>();
        
        print('✅ DEBUG: Preferences fetched successfully');
        print('✅ DEBUG: Total preferences: ${preferences.length}');
      } else {
        print('🔴 DEBUG: Failed to fetch preferences');
        print('🔴 DEBUG: Error: ${response.message}');
      }
      
      return response;
    } catch (e) {
      print('🔴 DEBUG: Exception while fetching preferences: $e');
      return ApiResponse.error(message: 'Failed to fetch preferences');
    }
  }

  /// Update a specific preference
  Future<ApiResponse> updatePreference(
    String preferenceId,
    Map<String, dynamic> updateData,
  ) async {
    print('🔵 DEBUG: Calling API - PUT ${AppConstants.baseUrl}/api/preferences/$preferenceId');
    print('🔵 DEBUG: Request Body: ${updateData.toString()}');
    
    try {
      final response = await ApiService.call(
        method: HttpMethod.put,
        path: ['api', 'preferences', preferenceId],
        body: updateData,
        logParams: 'Updating preference $preferenceId',
      );
      
      print('🟢 DEBUG: Response Status Code: ${response.statusCode}');
      print('🟢 DEBUG: Response Body: ${response.data}');
      
      if (response.success) {
        print('✅ DEBUG: Preference updated successfully');
        
        // Refresh preferences list
        await getPreferences();
      } else {
        print('🔴 DEBUG: Failed to update preference');
        print('🔴 DEBUG: Error: ${response.message}');
      }
      
      return response;
    } catch (e) {
      print('🔴 DEBUG: Exception while updating preference: $e');
      return ApiResponse.error(message: 'Failed to update preference');
    }
  }

  /// Delete a specific preference
  Future<ApiResponse> deletePreference(String preferenceId) async {
    print('🔵 DEBUG: Calling API - DELETE ${AppConstants.baseUrl}/api/preferences/$preferenceId');
    
    try {
      final response = await ApiService.call(
        method: HttpMethod.delete,
        path: ['api', 'preferences', preferenceId],
        logParams: 'Deleting preference $preferenceId',
      );
      
      print('🟢 DEBUG: Response Status Code: ${response.statusCode}');
      print('🟢 DEBUG: Response Body: ${response.data}');
      
      if (response.success) {
        print('✅ DEBUG: Preference deleted successfully');
        
        // Refresh preferences list
        await getPreferences();
      } else {
        print('🔴 DEBUG: Failed to delete preference');
        print('🔴 DEBUG: Error: ${response.message}');
      }
      
      return response;
    } catch (e) {
      print('🔴 DEBUG: Exception while deleting preference: $e');
      return ApiResponse.error(message: 'Failed to delete preference');
    }
  }

  /// Search preferences
  Future<ApiResponse> searchPreferences({
    required String query,
    String type = 'both',
  }) async {
    print('🔵 DEBUG: Calling API - GET ${AppConstants.baseUrl}/api/preferences/search');
    
    final params = <String, dynamic>{
      'q': query,
      'type': type,
    };
    
    print('🔵 DEBUG: Query Parameters: $params');
    
    try {
      final response = await ApiService.call(
        method: HttpMethod.get,
        path: ['api', 'preferences', 'search'],
        params: params,
        logParams: 'Searching preferences',
      );
      
      print('🟢 DEBUG: Response Status Code: ${response.statusCode}');
      print('🟢 DEBUG: Response Body: ${response.data}');
      
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final preferencesList = data['preferences'] as List<dynamic>;
        
        preferences.value = preferencesList.cast<Map<String, dynamic>>();
        
        print('✅ DEBUG: Preferences search completed');
        print('✅ DEBUG: Found ${preferences.length} matching preferences');
      } else {
        print('🔴 DEBUG: Failed to search preferences');
        print('🔴 DEBUG: Error: ${response.message}');
      }
      
      return response;
    } catch (e) {
      print('🔴 DEBUG: Exception while searching preferences: $e');
      return ApiResponse.error(message: 'Failed to search preferences');
    }
  }

  /// Check preference status
  Future<ApiResponse> checkPreferenceStatus() async {
    print('🔵 DEBUG: Calling API - GET ${AppConstants.baseUrl}/api/preferences/status');
    
    try {
      final response = await ApiService.call(
        method: HttpMethod.get,
        path: ['api', 'preferences', 'status'],
        logParams: 'Checking preference status',
      );
      
      print('🟢 DEBUG: Response Status Code: ${response.statusCode}');
      print('🟢 DEBUG: Response Body: ${response.data}');
      
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        hasPreferences.value = data['hasPreferences'] ?? false;
        totalCount.value = data['totalCount'] ?? 0;
        activeCount.value = data['activeCount'] ?? 0;
        lastUpdated.value = data['lastUpdated']?.toString() ?? '';
        
        print('✅ DEBUG: Preference status loaded successfully');
        print('✅ DEBUG: hasPreferences: ${hasPreferences.value}');
        print('✅ DEBUG: totalCount: ${totalCount.value}');
        print('✅ DEBUG: activeCount: ${activeCount.value}');
      } else {
        print('🔴 DEBUG: Failed to check preference status');
        print('🔴 DEBUG: Error: ${response.message}');
      }
      
      return response;
    } catch (e) {
      print('🔴 DEBUG: Exception while checking preference status: $e');
      return ApiResponse.error(message: 'Failed to check preference status');
    }
  }

  /// Get the first active preference (for quick access)
  Map<String, dynamic>? getFirstActivePreference() {
    final activePrefs = preferences.where((pref) => pref['isActive'] == true).toList();
    if (activePrefs.isNotEmpty) {
      print('🔍 DEBUG: Found ${activePrefs.length} active preferences');
      print('🔍 DEBUG: Returning first active preference: ${activePrefs.first}');
      return activePrefs.first;
    }
    print('🔍 DEBUG: No active preferences found');
    return null;
  }

  /// Get preferred card name from first active preference
  String? getPreferredCardName() {
    print('🔍 DEBUG: Getting preferred card name');
    final firstPref = getFirstActivePreference();
    if (firstPref != null) {
      final cardName = firstPref['cardName']?.toString();
      print('🔍 DEBUG: Preferred card name: $cardName');
      return cardName;
    }
    print('🔍 DEBUG: No preferred card name found');
    return null;
  }

  /// Get preferred bank name from first active preference
  String? getPreferredBankName() {
    print('🔍 DEBUG: Getting preferred bank name');
    final firstPref = getFirstActivePreference();
    if (firstPref != null) {
      final bankName = firstPref['bankName']?.toString();
      print('🔍 DEBUG: Preferred bank name: $bankName');
      return bankName;
    }
    print('🔍 DEBUG: No preferred bank name found');
    return null;
  }

  /// Clear all preferences from memory
  void clearPreferences() {
    preferences.clear();
    hasPreferences.value = false;
    totalCount.value = 0;
    activeCount.value = 0;
    lastUpdated.value = '';
    print('🧹 DEBUG: Preferences cleared from memory');
  }

  /// Force refresh preferences and status
  Future<void> forceRefresh() async {
    print('🔄 DEBUG: Force refreshing preferences');
    await checkPreferenceStatus();
    if (hasPreferences.value) {
      await getPreferences();
    }
    print('✅ DEBUG: Force refresh completed');
  }
} 