class FriendModel {
  final String id;
  final String userId;       // هذا المستخدم الحالي
  final String friendId;     // المستخدم المضاف كصديق
  final DateTime createdAt;

  FriendModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'friendId': friendId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory FriendModel.fromJson(Map<String, dynamic> json) => FriendModel(
    id: json['id'],
    userId: json['userId'],
    friendId: json['friendId'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}