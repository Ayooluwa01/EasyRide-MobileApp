class RideWebsocketMessageModel {
  final String id;
  final String rideId;
  final String senderId;
  final String content;
  final DateTime? readAt;
  final DateTime createdAt;
  final bool isMe;

  RideWebsocketMessageModel({
    required this.id,
    required this.rideId,
    required this.senderId,
    required this.content,
    this.readAt,
    required this.createdAt,
    required this.isMe,
  });

  factory RideWebsocketMessageModel.fromJson(Map<String, dynamic> json) {
    return RideWebsocketMessageModel(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isMe: json['isMe'] as bool,
    );
  }
}
