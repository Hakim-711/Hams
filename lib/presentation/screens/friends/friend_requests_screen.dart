import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hams/core/network/api_service.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final userId = await _storage.read(key: 'biometric_user_id');
    if (userId == null) return;

    try {
      final data = await ApiService.get('friends/pending/$userId');
      setState(() {
        _requests = List<Map<String, dynamic>>.from(data['requests']);
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
                    final r = _requests[index]['fromUser'];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(r['profileImagePath'] ?? ''),
                      ),
                      title: Text(r['username']),
                      subtitle: Text(r['userId']),
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
