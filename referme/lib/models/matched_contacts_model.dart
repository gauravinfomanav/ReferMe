class MatchedContactsResponse {
  final bool success;
  final String message;
  final MatchedContactsData data;

  MatchedContactsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MatchedContactsResponse.fromJson(Map<String, dynamic> json) {
    return MatchedContactsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: MatchedContactsData.fromJson(json['data'] ?? {}),
    );
  }
}

class MatchedContactsData {
  final List<MatchedUser> matchedUsers;
  final List<UnmatchedContact> unmatchedContacts;

  MatchedContactsData({
    required this.matchedUsers,
    required this.unmatchedContacts,
  });

  factory MatchedContactsData.fromJson(Map<String, dynamic> json) {
    return MatchedContactsData(
      matchedUsers: (json['matchedUsers'] as List?)
          ?.map((e) => MatchedUser.fromJson(e))
          .toList() ?? [],
      unmatchedContacts: (json['unmatchedContacts'] as List?)
          ?.map((e) => UnmatchedContact.fromJson(e))
          .toList() ?? [],
    );
  }
}

class MatchedUser {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String contactName;
  final List<String> cards;
  final bool hasCards;

  MatchedUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.contactName,
    required this.cards,
    required this.hasCards,
  });

  factory MatchedUser.fromJson(Map<String, dynamic> json) {
    return MatchedUser(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      contactName: json['contactName'] ?? '',
      cards: (json['cards'] as List?)?.map((e) => e.toString()).toList() ?? [],
      hasCards: json['hasCards'] ?? false,
    );
  }
}

class UnmatchedContact {
  final String name;
  final String phone;
  final String email;

  UnmatchedContact({
    required this.name,
    required this.phone,
    required this.email,
  });

  factory UnmatchedContact.fromJson(Map<String, dynamic> json) {
    return UnmatchedContact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
} 