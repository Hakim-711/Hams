// ✅ Updated: lib/features/chat/edit_room_screen.dart
import 'package:flutter/material.dart';
import 'package:hams/data/local/models/room_model.dart';
import 'package:hams/core/network/api_service.dart';

class EditRoomScreen extends StatefulWidget {
  final RoomModel room;
  const EditRoomScreen({super.key, required this.room});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  late TextEditingController _titleController;
  late String _selectedCategory;
  List<String> _selectedUsers = [];
  final List<String> _availableCategories = ['أصدقاء', 'عمل', 'مشفّرة'];
  final List<String> _availableUserIds = ['hakim', 'ali', 'sara', 'omar'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.room.title);
    _selectedCategory = widget.room.category;
    _selectedUsers = List<String>.from(widget.room.participants);
  }

  Future<void> _updateRoom() async {
    if (_titleController.text.isEmpty) {
      _showError('يرجى إدخال اسم الغرفة');
      return;
    }

    final updatedRoom = widget.room.copyWith(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      participants: _selectedUsers,
    );

    await ApiService.put("rooms/${updatedRoom.id}",
        data: RoomModel.fromEntity(updatedRoom).toJson());
    Navigator.pop(context, true);
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
              child: const Text('حسنًا')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('تعديل الغرفة'),
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
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 20),
            const Text('تعديل المشاركين:',
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
                onPressed: _updateRoom,
                icon: const Icon(Icons.save),
                label: const Text('حفظ التعديلات'),
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
