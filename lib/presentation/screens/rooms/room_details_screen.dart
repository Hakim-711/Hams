// 📁 lib/features/chat/room_details_screen.dart
import 'package:flutter/material.dart';
import 'package:hams/data/local/models/room_model.dart';


class RoomDetailsScreen extends StatelessWidget {
  final RoomModel room;
  const RoomDetailsScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(room.color);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(room.title),
        backgroundColor: color.withOpacity(0.2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [color.withOpacity(0.6), Colors.transparent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 12,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      room.title.substring(0, 1),
                      style: const TextStyle(fontSize: 48, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text("اسم الغرفة:", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
              Text(room.title, style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white)),
              const SizedBox(height: 20),
              Text("الفئة:", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
              Text(room.category, style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 20),
              Text("المستخدمون:", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
              ...room.participants.map((userId) => ListTile(
                    leading: const Icon(Icons.person, color: Colors.white54),
                    title: Text(userId, style: const TextStyle(color: Colors.white)),
                  )),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/chat', arguments: room);
                  },
                  icon: const Icon(Icons.chat_bubble),
                  label: const Text("ابدأ المحادثة"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
