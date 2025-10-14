import 'package:hams/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<void> saveUser(UserEntity user);
  Future<UserEntity?> getUserById(String userId);
  Future<List<UserEntity>> getAllUsers();
  Future<void> deleteUser(String userId);
  Future<void> updateUser(UserEntity user);
}
