class ReferralRequest {
  final String targetUserId;
  final String message;

  ReferralRequest({
    required this.targetUserId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'targetUserId': targetUserId,
      'message': message,
    };
  }
}

class ReferralMessage {
  final String message;
  final String link;

  ReferralMessage({
    required this.message,
    required this.link,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'link': link,
    };
  }
}

class ReferralUser {
  final String id;
  final String name;
  final String email;
  final String phone;

  ReferralUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory ReferralUser.fromJson(Map<String, dynamic> json) {
    return ReferralUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class ReferralMessageData {
  final String id;
  final String referralId;
  final String senderId;
  final String receiverId;
  final String message;
  final String link;
  final String type;
  final bool isRead;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReferralMessageData({
    required this.id,
    required this.referralId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.link,
    required this.type,
    required this.isRead,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReferralMessageData.fromJson(Map<String, dynamic> json) {
    return ReferralMessageData(
      id: json['id'] ?? '',
      referralId: json['referralId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      link: json['link'] ?? '',
      type: json['type'] ?? '',
      isRead: json['isRead'] ?? false,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        (json['expiresAt']?['_seconds'] ?? 0) * 1000,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt']?['_seconds'] ?? 0) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['updatedAt']?['_seconds'] ?? 0) * 1000,
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String referralId;
  final String senderId;
  final String receiverId;
  final String message;
  final String? link;
  final String type;
  final bool isRead;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isInitialMessage;

  ChatMessage({
    required this.id,
    required this.referralId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.link,
    required this.type,
    required this.isRead,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.isInitialMessage = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      referralId: json['referralId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      link: json['link'],
      type: json['type'] ?? '',
      isRead: json['isRead'] ?? false,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['expiresAt']['_seconds'] ?? 0) * 1000,
            )
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt']?['_seconds'] ?? 0) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['updatedAt']?['_seconds'] ?? 0) * 1000,
      ),
      isInitialMessage: json['isInitialMessage'] ?? false,
    );
  }
}

class Referral {
  final String id;
  final String requesterId;
  final String targetUserId;
  final String status;
  final String message;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String type;
  final ReferralUser? otherUser;
  final String? userRole;
  final ReferralMessageData? referralMessage;
  final List<ChatMessage>? chatHistory;
  final int? messageCount;

  Referral({
    required this.id,
    required this.requesterId,
    required this.targetUserId,
    required this.status,
    required this.message,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.type = '',
    this.otherUser,
    this.userRole,
    this.referralMessage,
    this.chatHistory,
    this.messageCount,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] ?? '',
      requesterId: json['requesterId'] ?? '',
      targetUserId: json['targetUserId'] ?? '',
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt']?['_seconds'] ?? 0) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['updatedAt']?['_seconds'] ?? 0) * 1000,
      ),
      type: json['type'] ?? '',
      otherUser: json['otherUser'] != null 
          ? ReferralUser.fromJson(json['otherUser']) 
          : null,
      userRole: json['userRole'],
      referralMessage: json['message'] is Map 
          ? ReferralMessageData.fromJson(json['message']) 
          : null,
      chatHistory: json['chatHistory'] != null 
          ? (json['chatHistory'] as List)
              .map((item) => ChatMessage.fromJson(item))
              .toList()
          : null,
      messageCount: json['messageCount'],
    );
  }
}

class ReferralResponse {
  final bool success;
  final String message;
  final ReferralData? data;
  final String timestamp;

  ReferralResponse({
    required this.success,
    required this.message,
    this.data,
    required this.timestamp,
  });

  factory ReferralResponse.fromJson(Map<String, dynamic> json) {
    return ReferralResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ReferralData.fromJson(json['data']) : null,
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class ReferralData {
  final Referral? referral;
  final List<Referral>? referrals;
  final ReferralMessageData? message;

  ReferralData({
    this.referral,
    this.referrals,
    this.message,
  });

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    return ReferralData(
      referral: json['referral'] != null 
          ? Referral.fromJson(json['referral']) 
          : null,
      referrals: json['referrals'] != null 
          ? (json['referrals'] as List)
              .map((item) => Referral.fromJson(item))
              .toList()
          : null,
      message: json['message'] != null 
          ? ReferralMessageData.fromJson(json['message']) 
          : null,
    );
  }
} 