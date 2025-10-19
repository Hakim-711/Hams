import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _userIdKey = 'user_id';
  static const String _biometricUserIdKey = 'biometric_user_id';
  static const String _tokenKey = 'auth_token';

  static Future<void> saveSession({
    required String userId,
    String? token,
  }) async {
    final tasks = <Future<void>>[
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _biometricUserIdKey, value: userId),
    ];

    if (token != null) {
      tasks.add(_storage.write(key: _tokenKey, value: token));
    } else {
      tasks.add(_storage.delete(key: _tokenKey));
    }

    await Future.wait(tasks);
  }

  static Future<String?> getUserId() => _storage.read(key: _userIdKey);

  static Future<String?> getBiometricUserId() =>
      _storage.read(key: _biometricUserIdKey);

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _biometricUserIdKey),
      _storage.delete(key: _tokenKey),
    ]);
  }
}
