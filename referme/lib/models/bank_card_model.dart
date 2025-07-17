class BankCardModel {
  final String bank;
  final String logo;
  final List<String> cards;

  BankCardModel({
    required this.bank,
    required this.logo,
    required this.cards,
  });

  factory BankCardModel.fromJson(Map<String, dynamic> json) {
    return BankCardModel(
      bank: json['bank'] as String,
      logo: json['logo'] as String,
      cards: List<String>.from(json['cards'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank': bank,
      'logo': logo,
      'cards': cards,
    };
  }
} 