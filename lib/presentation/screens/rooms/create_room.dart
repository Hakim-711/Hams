import 'package:flutter/material.dart';
import 'package:hams/data/local/models/room_model.dart';
import 'package:hams/core/network/api_service.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<String> _availableCategories = ['أصدقاء', 'عمل', 'مشفّرة'];
  final List<String> _availableUserIds = ['hakim', 'ali', 'sara', 'omar'];
  String? _selectedCategory;
  final List<String> _selectedUsers = [];

  Future<void> _saveRoom() async {
    if (_titleController.text.isEmpty || _selectedCategory == null) {
      _showError('يرجى تعبئة الاسم واختيار الفئة.');
      return;
    }

    final newRoom = RoomModel(
      title: _titleController.text.trim(),
      category: _selectedCategory!,
      color: Colors
          .primaries[
              DateTime.now().millisecondsSinceEpoch % Colors.primaries.length]
          .value,
      participants: _selectedUsers,
      isMuted: false,
      isPinned: false,
      lastMessage: '',
      unreadCount: 0,
      createdAt: DateTime.now(),
    );

    try {
      await ApiService.post("rooms", data: newRoom.toJson());
      Navigator.pop(context, true);
    } catch (e) {
      _showError("فشل إنشاء الغرفة: $e");
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسنًا'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('إنشاء غرفة جديدة'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'اسم الغرفة',
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.grey[900],
              decoration: const InputDecoration(
                labelText: 'الفئة',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              value: _selectedCategory,
              items: _availableCategories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 20),
            const Text('أضف مستخدمين (اختياري):',
                style: TextStyle(color: Colors.white70)),
            Wrap(
              spacing: 8,
              children: _availableUserIds.map((userId) {
                final isSelected = _selectedUsers.contains(userId);
                return FilterChip(
                  selected: isSelected,
                  label: Text(userId),
                  onSelected: (selected) {
                    setState(() {
                      isSelected
                          ? _selectedUsers.remove(userId)
                          : _selectedUsers.add(userId);
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveRoom,
                icon: const Icon(Icons.check),
                label: const Text('إنشاء الغرفة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
