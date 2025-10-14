// import 'dart:convert';
// import 'package:hams/core/network/api_service.dart';

// class FriendRepository {
//   Future<List<Map<String, dynamic>>> getFriends(String userId) async {
//     final res = await ApiService.get('/friends/list/$userId');
//     final data = jsonDecode(res.body);
//     return List<Map<String, dynamic>>.from(data['friends']);
//   }

//   Future<Map<String, dynamic>?> acceptRequest(int requestId) async {
//     final res = await ApiService.post('/friends/accept', {
//       'requestId': requestId,
//     });
//     if (res.statusCode == 200) {
//       return jsonDecode(res.body)['room'];
//     }
//     return null;
//   }
// }