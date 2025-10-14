import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoggedOut extends AuthEvent {}

class AuthCheckSession extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String userId;
  final String passcode;

  const AuthLoginRequested(this.userId, this.passcode);

  @override
  List<Object?> get props => [userId, passcode];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthRegisterRequested extends AuthEvent {
  final UserEntity user;

  const AuthRegisterRequested(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateUserRequested extends AuthEvent {
  final UserEntity updatedUser;

  const UpdateUserRequested(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}
