class FriendRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String sentAt;
  final bool isAccepted;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.sentAt,
    required this.isAccepted,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      sentAt: json['sentAt'],
      isAccepted: json['isAccepted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'sentAt': sentAt,
      'isAccepted': isAccepted,
    };
  }
}
