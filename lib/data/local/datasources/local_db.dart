// import 'package:hams/data/local/models/message_model.dart';
// import 'package:hams/data/local/models/private_folder_model.dart';
// import 'package:hams/data/local/models/room_model.dart';
// import 'package:hams/data/local/models/user_model.dart';
// import 'package:hams/core/utils/encryption_helper.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class LocalDB {
//   static Database? _db;

//   static Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await initDB();
//     return _db!;
//   }

//   static Future<Database> initDB() async {
//     final path = join(await getDatabasesPath(), 'hams.db');
//     return await openDatabase(
//       path,
//       version: 3,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE users (
//             userId TEXT PRIMARY KEY,
//             username TEXT,
//             profileImagePath TEXT,
//             passcode TEXT,
//             createdAt TEXT
//           )
//         ''');

//         await db.execute('''
//           CREATE TABLE rooms (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             title TEXT,
//             category TEXT,
//             color INTEGER,
//             participants TEXT,
//             isMuted INTEGER,
//             isPinned INTEGER,
//             lastMessage TEXT,
//             unreadCount INTEGER,
//             createdAt TEXT
//           )
//         ''');

//         await db.execute('''
//           CREATE TABLE messages (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             roomId TEXT,
//             senderId TEXT,
//             content TEXT,
//             isEncrypted INTEGER,
//             sentAt TEXT,
//             isSelfDestruct INTEGER DEFAULT 0,
//             selfDestructDuration INTEGER DEFAULT 0,
//             isRead INTEGER DEFAULT 0
//           )
//         ''');

//         await db.execute('''
//           CREATE TABLE private_folders (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             title TEXT,
//             userIds TEXT,
//             createdAt TEXT
//           )
//         ''');
//       },
//     );
//   }

//   // ========== Users ==========
//   static Future<void> insertUser(UserModel user) async {
//     final db = await database;
//     await db.insert('users', user.toMap(),
//         conflictAlgorithm: ConflictAlgorithm.replace);
//   }

//   static Future<void> updateUser(UserModel user) async {
//     final db = await database;
//     await db.update(
//       'users',
//       user.toMap(),
//       where: 'userId = ?',
//       whereArgs: [user.userId],
//     );
//   }

//   static Future<List<UserModel>> getAllUsers() async {
//     final db = await database;
//     final result = await db.query('users');
//     return result.map((e) => UserModel.fromMap(e)).toList();
//   }

//   // ========== Rooms ==========
//   static Future<void> insertRoom(RoomModel room) async {
//     final db = await database;
//     await db.insert('rooms', room.toMap());
//   }

//   static Future<void> updateRoom(RoomModel room) async {
//     final db = await database;
//     await db
//         .update('rooms', room.toMap(), where: 'id = ?', whereArgs: [room.id]);
//   }

//   static Future<void> deleteRoom(int id) async {
//     final db = await database;
//     await db.delete('rooms', where: 'id = ?', whereArgs: [id]);
//   }

//   static Future<List<RoomModel>> getAllRooms() async {
//     final db = await database;
//     final result = await db.query('rooms');
//     return result.map((e) => RoomModel.fromMap(e)).toList();
//   }

//   // ========== Messages ==========
//   static Future<void> insertMessage(MessageModel message) async {
//     final db = await database;
//     final encryptedContent = message.isEncrypted
//         ? EncryptionHelper.encrypt(message.content)
//         : message.content;
//     await db.insert('messages', {
//       ...message.toMap(),
//       'content': encryptedContent,
//     });
//   }

//   static Future<void> updateMessage(MessageModel message) async {
//     final db = await database;
//     await db.update('messages', message.toMap(),
//         where: 'id = ?', whereArgs: [message.id]);
//   }

//   static Future<void> deleteMessage(int id) async {
//     final db = await database;
//     await db.delete('messages', where: 'id = ?', whereArgs: [id]);
//   }

//   static Future<List<MessageModel>> getAllMessages() async {
//     final db = await database;
//     final result = await db.query('messages');
//     return result.map((e) {
//       final isEncrypted = e['isEncrypted'] == 1;
//       final decryptedContent = isEncrypted
//           ? EncryptionHelper.decrypt(e['content'] as String)
//           : e['content'] as String;
//       return MessageModel.fromMap({
//         ...e,
//         'content': decryptedContent,
//       });
//     }).toList();
//   }

//   static Future<List<MessageModel>> getMessagesBySenderId(
//       String senderId) async {
//     final db = await database;
//     final result = await db
//         .query('messages', where: 'senderId = ?', whereArgs: [senderId]);
//     return result.map((e) {
//       final isEncrypted = e['isEncrypted'] == 1;
//       final decryptedContent = isEncrypted
//           ? EncryptionHelper.decrypt(e['content'] as String)
//           : e['content'] as String;
//       return MessageModel.fromMap({
//         ...e,
//         'content': decryptedContent,
//       });
//     }).toList();
//   }

//   static Future<List<MessageModel>> getMessagesByRoomAndSenderId(
//       String roomId, String senderId) async {
//     final db = await database;
//     final result = await db.query('messages',
//         where: 'roomId = ? AND senderId = ?', whereArgs: [roomId, senderId]);
//     return result.map((e) {
//       final isEncrypted = e['isEncrypted'] == 1;
//       final decryptedContent = isEncrypted
//           ? EncryptionHelper.decrypt(e['content'] as String)
//           : e['content'] as String;
//       return MessageModel.fromMap({
//         ...e,
//         'content': decryptedContent,
//       });
//     }).toList();
//   }

//   static Future<List<MessageModel>> getMessagesByRoomAndSenderIdAndSelfDestruct(
//       String roomId, String senderId) async {
//     final db = await database;
//     final result = await db.query('messages',
//         where: 'roomId = ? AND senderId = ? AND isSelfDestruct = 1',
//         whereArgs: [roomId, senderId]);
//     return result.map((e) {
//       final isEncrypted = e['isEncrypted'] == 1;
//       final decryptedContent = isEncrypted
//           ? EncryptionHelper.decrypt(e['content'] as String)
//           : e['content'] as String;
//       return MessageModel.fromMap({
//         ...e,
//         'content': decryptedContent,
//       });
//     }).toList();
//   }

//   static Future<List<MessageModel>> getMessagesByRoomAndSelfDestruct(
//       String roomId) async {
//     final db = await database;
//     final result = await db.query('messages',
//         where: 'roomId = ? AND isSelfDestruct = 1', whereArgs: [roomId]);
//     return result.map((e) {
//       final isEncrypted = e['isEncrypted'] == 1;
//       final decryptedContent = isEncrypted
//           ? EncryptionHelper.decrypt(e['content'] as String)
//           : e['content'] as String;
//       return MessageModel.fromMap({
//         ...e,
//         'content': decryptedContent,
//       });
//     }).toList();
//   }

//   static Future<void> deleteMessagesByUserId(String userId) async {
//     final db = await database;
//     await db.delete('messages', where: 'senderId = ?', whereArgs: [userId]);
//   }

//   static Future<List<MessageModel>> getMessagesByRoom(String roomId) async {
//     final db = await database;
//     final result =
//         await db.query('messages', where: 'roomId = ?', whereArgs: [roomId]);
//     return result.map((e) {
//       final isEncrypted = e['isEncrypted'] == 1;
//       final decryptedContent = isEncrypted
//           ? EncryptionHelper.decrypt(e['content'] as String)
//           : e['content'] as String;
//       return MessageModel.fromMap({
//         ...e,
//         'content': decryptedContent,
//       });
//     }).toList();
//   }

//   // ========== Private Folders ==========
//   static Future<void> insertFolder(PrivateFolderModel folder) async {
//     final db = await database;
//     await db.insert('private_folders', folder.toMap());
//   }

//   static Future<List<PrivateFolderModel>> getAllFolders() async {
//     final db = await database;
//     final result = await db.query('private_folders');
//     return result.map((e) => PrivateFolderModel.fromMap(e)).toList();
//   }

//   static Future<void> deleteFolder(int id) async {
//     final db = await database;
//     await db.delete('private_folders', where: 'id = ?', whereArgs: [id]);
//   }

//   static Future<void> deleteUser(String userId) async {
//     final db = await database;
//     await db.delete('users', where: 'userId = ?', whereArgs: [userId]);
//   }

//   static Future<void> deleteMessagesBySenderId(String senderId) async {
//     final db = await database;
//     await db.delete('messages', where: 'senderId = ?', whereArgs: [senderId]);
//   }

//   static Future<void> deletePrivateRoomsByUserId(String userId) async {
//     final db = await database;
//     await db.delete('rooms',
//         where: 'participants LIKE ?', whereArgs: ['%$userId%']);
//   }

//   static Future<void> deleteFoldersByUserId(String userId) async {
//     final db = await database;
//     await db.delete('private_folders',
//         where: 'userIds LIKE ?', whereArgs: ['%$userId%']);
//   }

//   static Future<void> markMessagesAsRead(String roomId, String userId) async {
//     final db = await database;
//     await db.update(
//       'messages',
//       {'isRead': 1},
//       where: 'roomId = ? AND senderId != ?',
//       whereArgs: [roomId, userId],
//     );
//   }

//   static Future<void> deleteSelfDestructMessages(
//       String roomId, String userId) async {
//     final db = await database;
//     await db.delete(
//       'messages',
//       where:
//           'roomId = ? AND senderId != ? AND isSelfDestruct = 1 AND isRead = 1',
//       whereArgs: [roomId, userId],
//     );
//   }
// }
