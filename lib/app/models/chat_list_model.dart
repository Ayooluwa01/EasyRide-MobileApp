class ChatListModel {
  final bool success;
  final int statusCode;
  final ChatListData data;
  ChatListModel({
    required this.success,
    required this.statusCode,
    required this.data,
  });

  factory ChatListModel.fromJson(Map<String, dynamic> json) {
    return ChatListModel(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      data: ChatListData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ChatListData {
  final List<ChatConversation> conversations;
  ChatListData({required this.conversations});
  factory ChatListData.fromJson(Map<String, dynamic> json) {
    return ChatListData(
      conversations: (json['conversations'] as List)
          .map(
            (conversation) =>
                ChatConversation.fromJson(conversation as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class ChatConversation {
  final String rideId;
  final ChatReceiver receiver;
  final String status;

  ChatConversation({
    required this.rideId,
    required this.receiver,
    required this.status,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      rideId: json['rideId'] as String,
      receiver: ChatReceiver.fromJson(json['receiver'] as Map<String, dynamic>),
      status: json['status'] as String,
    );
  }
}

class ChatReceiver {
  final String id;
  final String fullName;
  final String? profilePhotoUrl;

  ChatReceiver({
    required this.id,
    required this.fullName,
    this.profilePhotoUrl,
  });

  factory ChatReceiver.fromJson(Map<String, dynamic> json) {
    return ChatReceiver(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }
}
