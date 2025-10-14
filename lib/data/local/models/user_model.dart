import 'package:hams/domain/entities/user_entity.dart';


class UserModel extends UserEntity {
  const UserModel({
    required super.userId,
    required super.username,
    required super.passcode,
    required super.profileImagePath,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      username: json['username'],
      passcode: json['passcode'],
      profileImagePath: json['profileImagePath'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'passcode': passcode,
      'profileImagePath': profileImagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static UserModel empty() {
    return UserModel(
      userId: '',
      username: '',
      passcode: '',
      profileImagePath: '',
      createdAt: DateTime.now(),
    );
  }
}