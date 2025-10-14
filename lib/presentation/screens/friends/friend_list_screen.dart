// import 'package:flutter/material.dart';
// import 'package:hams/presentation/screens/chat/chat_screen.dart';
// import 'package:hams/repositories/friend_repository.dart';
// import 'package:hams/screens/chat/chat_screen.dart';

// class FriendListScreen extends StatefulWidget {
//   final String userId;

//   const FriendListScreen({super.key, required this.userId});

//   @override
//   State<FriendListScreen> createState() => _FriendListScreenState();
// }

// class _FriendListScreenState extends State<FriendListScreen> {
//   List<Map<String, dynamic>> friends = [];

//   @override
//   void initState() {
//     super.initState();
//     loadFriends();
//   }

//   void loadFriends() async {
//     final data = await FriendRepository().getFriends(widget.userId);
//     setState(() {
//       friends = data;
//     });
//   }

//   void openChat(Map<String, dynamic> friend) async {
//     // هذا يفترض أن لديك room بينك وبين الصديق
//     // إذا لا يوجد، يجب إنشاء واحد هنا مستقبلاً
//     final roomId = await getRoomIdWithFriend(friend['userId']); // ← تكتبها حسب منطقك

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ChatScreen(
//           userId: widget.userId,
//           friendId: friend['userId'],
//           friendName: friend['username'],
//           roomId: roomId,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("My Friends")),
//       body: ListView.builder(
//         itemCount: friends.length,
//         itemBuilder: (context, index) {
//           final friend = friends[index];
//           return ListTile(
//             title: Text(friend['username']),
//             subtitle: Text(friend['userId']),
//             trailing: IconButton(
//               icon: Icon(Icons.chat_bubble),
//               onPressed: () => openChat(friend),
//             ),
//           );
//         },
//       ),
//     );
//   }

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hams/core/network/api_service.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final userId = await _storage.read(key: 'biometric_user_id');
    if (userId == null) return;

    try {
      final data = await ApiService.get('friends/list/$userId');
      setState(() {
        _friends = List<Map<String, dynamic>>.from(data['friends']);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load friends: $e');
      setState(() => _isLoading = false);
    }
  }

  void _openChat(Map<String, dynamic> friend) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'userId': friend['userId'],
        'username': friend['username'],
        'profileImagePath': friend['profileImagePath'],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأصدقاء')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _friends.isEmpty
              ? const Center(child: Text('لا يوجد أصدقاء بعد'))
              : ListView.builder(
                  itemCount: _friends.length,
                  itemBuilder: (context, index) {
                    final friend = _friends[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(friend['profileImagePath'] ?? ''),
                      ),
                      title: Text(friend['username']),
                      subtitle: Text(friend['userId']),
                      onTap: () => _openChat(friend),
                    );
                  },
                ),
    );
  }
}
