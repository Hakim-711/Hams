// import 'package:hams/data/local/datasources/local_db.dart';
// import 'package:hams/data/local/models/user_model.dart';
// import '../../domain/repositories/user_repository.dart';
// import '../../domain/entities/user_entity.dart';

// class UserRepositoryImpl implements UserRepository {
//   @override
//   Future<void> saveUser(UserEntity user) async {
//     final model = UserModel(
//       userId: user.userId,
//       username: user.username,
//       profileImagePath: user.profileImagePath,
//       passcode: user.passcode,
//       createdAt: user.createdAt,
//     );
//     await LocalDB.insertUser(model);
//   }

//   @override
//   Future<UserEntity?> getUserById(String userId) async {
//     final users = await LocalDB.getAllUsers();
//     final user = users.firstWhere((u) => u.userId == userId,
//         orElse: () => UserModel.empty());
//     if (user.userId.isEmpty) return null;
//     return UserEntity(
//       userId: user.userId,
//       username: user.username,
//       passcode: user.passcode,
//       profileImagePath: user.profileImagePath,
//       createdAt: user.createdAt,
//     );
//   }

//   @override
//   Future<void> updateUser(UserEntity user) async {
//     final model = UserModel(
//       userId: user.userId,
//       username: user.username,
//       profileImagePath: user.profileImagePath,
//       passcode: user.passcode,
//       createdAt: user.createdAt,
//     );
//     await LocalDB.updateUser(model);
//   }

//   @override
//   Future<List<UserEntity>> getAllUsers() async {
//     final users = await LocalDB.getAllUsers();
//     return users
//         .map((u) => UserEntity(
//               userId: u.userId,
//               username: u.username,
//               passcode: u.passcode,
//               profileImagePath: u.profileImagePath,
//               createdAt: u.createdAt,
//             ))
//         .toList();
//   }

//   @override
//   Future<void> deleteUser(String userId) async {
//     // يمكنك إنشاء دالة delete داخل LocalDB وتنفيذها هنا
//   }
// }import 'package:hams/data/models/user_model.dart';
import 'package:hams/data/local/models/user_model.dart';

import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/network/api_service.dart';

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
    final jsonList = await ApiService.get('auth/all');
    return (jsonList as List).map((e) => UserModel.fromJson(e)).toList();
  }

  @override
  Future<void> deleteUser(String userId) async {
    await ApiService.delete('auth/$userId');
  }
}