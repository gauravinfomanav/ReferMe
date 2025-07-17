import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bank_card_model.dart';

class CardSelectionController extends GetxController {
  final RxList<BankCardModel> banks = <BankCardModel>[].obs;
  final RxList<BankCardModel> filteredBanks = <BankCardModel>[].obs;
  final RxString selectedBank = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxList<String> selectedCards = <String>[].obs;
  static const String cardSelectionCompletedKey = 'card_selection_completed';
  static const String selectedCardsKey = 'selected_cards';

  @override
  void onInit() {
    super.onInit();
    loadBanks();
  }

  Future<void> loadBanks() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/utils/card_list.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      banks.value = jsonList.map((json) => BankCardModel.fromJson(json)).toList();
      filteredBanks.value = List.from(banks);
    } catch (e) {
      print('Error loading banks: $e');
    }
  }

  void selectBank(String bankName) {
    selectedBank.value = bankName;
  }

  void toggleCardSelection(String cardName) {
    if (selectedCards.contains(cardName)) {
      selectedCards.remove(cardName);
    } else {
      selectedCards.add(cardName);
    }
  }

  void searchCards(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredBanks.value = List.from(banks);
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    
    // Find banks that match either by bank name or have matching cards
    var matchingBanks = banks.where((bank) {
      // Check bank name
      final bankMatches = bank.bank.toLowerCase().contains(lowercaseQuery);
      // Check card names
      final hasMatchingCards = bank.cards.any((card) => 
        card.toLowerCase().contains(lowercaseQuery)
      );
      
      return bankMatches || hasMatchingCards;
    }).toList();

    // Update filtered banks
    filteredBanks.value = matchingBanks;

    // If searching by card name and only one bank has matching cards,
    // automatically select that bank
    if (matchingBanks.length == 1) {
      final bank = matchingBanks.first;
      if (bank.cards.any((card) => card.toLowerCase().contains(lowercaseQuery))) {
        selectBank(bank.bank);
      }
    }
  }

  List<String> getSelectedBankCards() {
    if (selectedBank.isEmpty) return [];
    
    // Find the selected bank
    final bank = banks.firstWhere(
      (bank) => bank.bank == selectedBank.value,
      orElse: () => BankCardModel(bank: '', logo: '', cards: []),
    );

    // If no search query, return all cards of selected bank
    if (searchQuery.isEmpty) return bank.cards;
    
    // Filter cards based on search query
    final query = searchQuery.value.toLowerCase();
    final matchingCards = bank.cards.where((card) =>
      card.toLowerCase().contains(query)
    ).toList();

    // If we found matching cards, return them
    if (matchingCards.isNotEmpty) {
      return matchingCards;
    }
    
    // If no cards match but we're still showing this bank,
    // it means the bank name matched, so show all cards
    if (filteredBanks.any((b) => b.bank == bank.bank)) {
      return bank.cards;
    }

    return [];
  }

  Future<void> saveCardSelectionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(cardSelectionCompletedKey, true);
    // Save selected cards
    await prefs.setStringList(selectedCardsKey, selectedCards.toList());
  }

  static Future<bool> isCardSelectionCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(cardSelectionCompletedKey) ?? false;
  }

  static Future<List<String>> getSavedCards() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(selectedCardsKey) ?? [];
  }

  void clearSelection() {
    selectedCards.clear();
    selectedBank.value = '';
    searchQuery.value = '';
    filteredBanks.value = List.from(banks);
  }
} 