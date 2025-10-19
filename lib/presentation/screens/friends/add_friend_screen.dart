import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:hams/core/network/api_service.dart';
import 'package:hams/core/storage/session_manager.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _idController = TextEditingController();
  Map<String, dynamic>? _foundUser;
  bool _isLoading = false;

  ImageProvider _buildAvatar(dynamic path) {
    if (path is String && path.isNotEmpty) {
      if (path.startsWith('http')) {
        return NetworkImage(path);
      }
    }
    return const AssetImage('assets/user_placeholder.png');
  }

  Future<void> _searchUser() async {
    setState(() => _isLoading = true);
    final id = _idController.text.trim();

    try {
      final user = await ApiService.get('auth/$id');
      setState(() {
        _foundUser = user.isEmpty ? null : user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _foundUser = null;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('User not found')));
    }
  }

  Future<void> _sendFriendRequest() async {
    if (_foundUser == null) return;

    final myId = await SessionManager.getUserId();

    if (myId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')));
      return;
    }

    try {
      await ApiService.post('friends/request', data: {
        'fromId': myId,
        'toId': _foundUser!['userId'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال طلب الصداقة ✅')));
      setState(() {
        _foundUser = null;
        _idController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('فشل إرسال الطلب: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Add Friend'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B1E2E), Color(0xFF0F0F1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            child: Column(
              children: [
                TextField(
                  controller: _idController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter Hams ID',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _searchUser(),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : _foundUser != null
                        ? Card(
                            color: Colors.white.withOpacity(0.05),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    _buildAvatar(_foundUser!['profileImagePath']),
                              ),
                              title: Text(
                                (_foundUser!['username'] ?? 'مستخدم') as String,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'ID: ${_foundUser!['userId'] ?? ''}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: ElevatedButton(
                                onPressed: _sendFriendRequest,
                                child: const Text('Send'),
                              ),
                            ),
                          )
                        : const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
