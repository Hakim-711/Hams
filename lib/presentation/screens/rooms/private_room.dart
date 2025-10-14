// 📁 lib/features/chat/private_folders_screen.dart
import 'package:flutter/material.dart';


class PrivateFolderScreen extends StatefulWidget {
  const PrivateFolderScreen({super.key});

  @override
  State<PrivateFolderScreen> createState() => _PrivateFolderScreenState();
}

class _PrivateFolderScreenState extends State<PrivateFolderScreen> {
  List<FolderModel> folders = [];

  void _createNewFolder() async {
    final newFolder = await showDialog<FolderModel>(
      context: context,
      builder: (_) => const CreateFolderDialog(),
    );

    if (newFolder != null) {
      setState(() {
        folders.add(newFolder);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تنظيم المحادثات"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewFolder,
          )
        ],
      ),
      body: folders.isEmpty
          ? const Center(child: Text("لا توجد مجلدات حتى الآن"))
          : ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(folder.title),
                    subtitle: Text("${folder.userIds.length} مستخدم"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FolderUsersScreen(folder: folder),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class FolderModel {
  final String title;
  final List<String> userIds;
  final DateTime createdAt;

  FolderModel({
    required this.title,
    required this.userIds,
    required this.createdAt,
  });
}

class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({super.key});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final TextEditingController _titleController = TextEditingController();
  final List<String> _selectedUsers = [];
  final List<String> allUsers = List.generate(10, (i) => 'مستخدم ${i + 1}');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("إنشاء مجلد جديد"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'اسم المجلد'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView(
              children: allUsers.map((user) {
                final selected = _selectedUsers.contains(user);
                return CheckboxListTile(
                  title: Text(user),
                  value: selected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedUsers.add(user);
                      } else {
                        _selectedUsers.remove(user);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("إلغاء"),
        ),
        ElevatedButton(
          onPressed: () {
            final folder = FolderModel(
              title: _titleController.text,
              userIds: _selectedUsers,
              createdAt: DateTime.now(),
            );
            Navigator.pop(context, folder);
          },
          child: const Text("إنشاء"),
        ),
      ],
    );
  }
}

class FolderUsersScreen extends StatelessWidget {
  final FolderModel folder;
  const FolderUsersScreen({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(folder.title)),
      body: ListView(
        children: folder.userIds.map((user) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user),
            onTap: () {
              // انتقل إلى شاشة الدردشة مع هذا المستخدم
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DummyChatScreen(name: user),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class DummyChatScreen extends StatelessWidget {
  final String name;
  const DummyChatScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("دردشة مع $name")),
      body: const Center(
        child: Text("هنا شاشة الدردشة 👋"),
      ),
    );
  }
}
