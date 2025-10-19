import 'package:flutter/material.dart';

import 'package:hams/core/network/api_service.dart';
import 'package:hams/core/storage/session_manager.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await ApiService.get('friends/pending/$userId');
      final requests = data['requests'];
      setState(() {
        _requests = requests is List
            ? requests
                .whereType<Map<String, dynamic>>()
                .toList(growable: false)
            : <Map<String, dynamic>>[];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load requests: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      await ApiService.post('friends/accept', data: {'requestId': requestId});
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم قبول الطلب ✅')));

      _loadRequests(); // تحديث القائمة
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('فشل القبول: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات الصداقة')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('لا توجد طلبات معلّقة'))
              : ListView.builder(
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final r = _requests[index]['fromUser']
                        as Map<String, dynamic>? ??
                        const <String, dynamic>{};
                    final username = (r['username'] ?? 'مستخدم مجهول') as String;
                    final userId = (r['userId'] ?? '') as String;
                    final avatar = r['profileImagePath'] as String?;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (avatar != null && avatar.isNotEmpty)
                            ? NetworkImage(avatar)
                            : const AssetImage('assets/user_placeholder.png')
                                as ImageProvider,
                      ),
                      title: Text(username),
                      subtitle: Text(userId),
                      trailing: ElevatedButton(
                        onPressed: () => _acceptRequest(_requests[index]['id']),
                        child: const Text('قبول'),
                      ),
                    );
                  },
                ),
    );
  }
}
