import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String userId;
  final String username;
  final String passcode;
  final String profileImagePath;
  final DateTime createdAt;

  const UserEntity({
    required this.userId,
    required this.username,
    required this.passcode,
    required this.profileImagePath,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        userId,
        username,
        passcode,
        profileImagePath,
        createdAt,
      ];
}