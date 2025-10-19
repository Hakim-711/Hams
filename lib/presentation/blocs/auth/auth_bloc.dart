import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hams/core/network/api_service.dart';
import 'package:hams/core/storage/session_manager.dart';
import '../../../domain/entities/user_entity.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckSession>(_onCheckSession);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogout);
    on<UpdateUserRequested>(_onUpdateUserRequested);
  }

  Future<void> _onCheckSession(
      AuthCheckSession event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userId = await SessionManager.getUserId();

      if (userId != null) {
        final response = await ApiService.get('auth/$userId');
        final user = UserEntity(
          userId: response['userId'] ?? userId,
          username: response['username'] ?? '',
          passcode: '',
          profileImagePath: response['profileImagePath'] ?? '',
          createdAt:
              DateTime.tryParse(response['createdAt'] ?? '') ?? DateTime.now(),
        );
        emit(AuthAuthenticated(user));
        return;
      }
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('فشل التحقق من الجلسة: $e'));
    }
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await ApiService.login(
        userId: event.userId,
        passcode: event.passcode,
      );

      final userJson = response['user'] ?? {};
      final sanitizedUser = UserEntity(
        userId: userJson['userId'] ?? event.userId,
        username: userJson['username'] ?? '',
        passcode: '',
        profileImagePath: userJson['profileImagePath'] ?? '',
        createdAt: DateTime.tryParse(userJson['createdAt'] ?? '') ??
            DateTime.now(),
      );

      await SessionManager.saveSession(
        userId: sanitizedUser.userId,
        token: response['token'] as String?,
      );

      emit(AuthAuthenticated(sanitizedUser));
    } catch (e) {
      emit(AuthError('فشل تسجيل الدخول: $e'));
    }
  }

  Future<void> _onRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await ApiService.register(
        userId: event.user.userId,
        username: event.user.username,
        passcode: event.user.passcode,
        profileImagePath: event.user.profileImagePath,
      );

      final userJson = response['user'] ?? {
        'userId': event.user.userId,
        'username': event.user.username,
        'profileImagePath': event.user.profileImagePath,
      };

      final sanitizedUser = UserEntity(
        userId: userJson['userId'] ?? event.user.userId,
        username: userJson['username'] ?? event.user.username,
        passcode: '',
        profileImagePath:
            userJson['profileImagePath'] ?? event.user.profileImagePath,
        createdAt: DateTime.tryParse(userJson['createdAt'] ?? '') ??
            event.user.createdAt,
      );

      await SessionManager.saveSession(
        userId: sanitizedUser.userId,
        token: response['token'] as String?,
      );

      emit(AuthAuthenticated(sanitizedUser));
    } catch (e) {
      emit(AuthError('فشل التسجيل: $e'));
    }
  }

  Future<void> _onUpdateUserRequested(
      UpdateUserRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final sanitizedUser = UserEntity(
        userId: event.updatedUser.userId,
        username: event.updatedUser.username,
        passcode: '',
        profileImagePath: event.updatedUser.profileImagePath,
        createdAt: event.updatedUser.createdAt,
      );
      emit(AuthAuthenticated(sanitizedUser));
    } catch (e) {
      emit(AuthError('فشل التحديث: $e'));
    }
  }

  void _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await SessionManager.clearSession();
    emit(AuthUnauthenticated());
  }
}
