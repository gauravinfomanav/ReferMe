class CardRequestModel {
  final String bankName;
  final String cardName;

  CardRequestModel({
    required this.bankName,
    required this.cardName,
  });

  Map<String, dynamic> toJson() => {
    'bankName': bankName,
    'cardName': cardName,
  };
}

class CardsRequest {
  final List<CardRequestModel> cards;

  CardsRequest({required this.cards});

  Map<String, dynamic> toJson() => {
    'cards': cards.map((card) => card.toJson()).toList(),
  };
} 