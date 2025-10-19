import 'package:hams/core/network/api_service.dart';
import 'package:hams/data/local/models/user_model.dart';
import 'package:hams/domain/entities/user_entity.dart';
import 'package:hams/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  @override
  Future<void> saveUser(UserEntity user) async {
    await ApiService.post('auth/register', data: {
      'userId': user.userId,
      'username': user.username,
      'passcode': user.passcode,
      'profileImagePath': user.profileImagePath,
      'createdAt': user.createdAt.toIso8601String(),
    });
  }

  @override
  Future<UserEntity?> getUserById(String userId) async {
    try {
      final json = await ApiService.get('auth/$userId');
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await ApiService.post('auth/update', data: {
      'userId': user.userId,
      'username': user.username,
      'passcode': user.passcode,
      'profileImagePath': user.profileImagePath,
      'createdAt': user.createdAt.toIso8601String(),
    });
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final jsonList = await ApiService.getList('auth/all');
    return jsonList.map(UserModel.fromJson).toList();
  }

  @override
  Future<void> deleteUser(String userId) async {
    await ApiService.delete('auth/$userId');
  }
}
