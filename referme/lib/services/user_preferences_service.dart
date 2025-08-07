import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _preferredCardKey = 'user_preferred_card';
  static const String _preferredCardBankKey = 'user_preferred_card_bank';

  /// Save user's preferred card
  static Future<void> savePreferredCard(String cardName, String bankName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredCardKey, cardName);
    await prefs.setString(_preferredCardBankKey, bankName);
  }

  /// Get user's preferred card name
  static Future<String?> getPreferredCard() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_preferredCardKey);
  }

  /// Get user's preferred card bank
  static Future<String?> getPreferredCardBank() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_preferredCardBankKey);
  }

  /// Check if user has set a preferred card
  static Future<bool> hasPreferredCard() async {
    final cardName = await getPreferredCard();
    return cardName != null && cardName.isNotEmpty;
  }

  /// Clear user's preferred card
  static Future<void> clearPreferredCard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_preferredCardKey);
    await prefs.remove(_preferredCardBankKey);
  }
} 