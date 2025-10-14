import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hams/core/network/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      const secureStorage = FlutterSecureStorage();

      final userId = await secureStorage.read(key: 'userId');
 
      if (userId != null) {
        final response = await ApiService.get('auth/$userId');
        final user = UserEntity(
          userId: response['userId'],
          username: response['username'],
          passcode: "", // ما يرجعه السيرفر بعد تسجيل الدخول
          profileImagePath: response['profileImagePath'] ?? '',
          createdAt: DateTime.now(), // هذا نستخدمه فقط محليًا
        );
        emit(AuthAuthenticated(user));
        return;
      }
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(const AuthError("فشل التحقق من الجلسة"));
    }
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await ApiService.post('auth/login', data: {
        'userId': event.userId,
        'passcode': event.passcode,
      });

      final userJson = response['user'];

      final user = UserEntity(
        userId: userJson['userId'],
        username: userJson['username'],
        passcode: event.passcode,
        profileImagePath: userJson['profileImagePath'] ?? '',
        createdAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.userId);

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(const AuthError("فشل تسجيل الدخول"));
    }
  }

  Future<void> _onRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await ApiService.post('auth/register', data: {
        'userId': event.user.userId,
        'username': event.user.username,
        'passcode': event.user.passcode,
        'profileImagePath': event.user.profileImagePath,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', event.user.userId);

      emit(AuthAuthenticated(event.user));
    } catch (e) {
      emit(const AuthError("فشل التسجيل"));
    }
  }

  Future<void> _onUpdateUserRequested(
      UpdateUserRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      emit(AuthAuthenticated(event.updatedUser));
    } catch (_) {
      emit(const AuthError("فشل التحديث"));
    }
  }

  void _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    emit(AuthUnauthenticated());
  }
}
