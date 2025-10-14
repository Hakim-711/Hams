// ✅ Updated: lib/features/chat/vibe_rooms_full_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hams/core/network/api_service.dart';
import 'package:hams/data/local/models/room_model.dart';
import 'package:hams/domain/entities/room_entity.dart';
import 'package:hams/presentation/routes/app_routes.dart';
import 'package:hams/presentation/screens/rooms/edit_room_screen.dart';
import 'create_room.dart';
import 'room_details_screen.dart';
import 'private_room.dart';

class VibeRoomsFullScreen extends StatefulWidget {
  const VibeRoomsFullScreen({super.key});

  @override
  State<VibeRoomsFullScreen> createState() => _VibeRoomsFullScreenState();
}

class _VibeRoomsFullScreenState extends State<VibeRoomsFullScreen> {
  List<RoomEntity> allRooms = [];
  List<String> categories = ["الكل", "أصدقاء", "عمل", "مشفّرة", "📵 مكتومة"];
  String selectedCategory = "الكل";
  bool isGrid = true;
  String searchQuery = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.get("rooms");
      setState(() => allRooms = (data as List)
          .map((room) => RoomModel.fromJson(room))
          .toList());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشل تحميل الغرف: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<RoomEntity> get filteredRooms {
    List<RoomEntity> rooms = selectedCategory == "الكل"
        ? allRooms
        : selectedCategory == "📵 مكتومة"
            ? allRooms.where((room) => room.isMuted).toList()
            : allRooms
                .where((room) => room.category == selectedCategory)
                .toList();

    if (searchQuery.isNotEmpty) {
      rooms = rooms
          .where((room) =>
              room.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return rooms;
  }

  void _toggleLayout() {
    setState(() => isGrid = !isGrid);
  }

  Future<void> _createRoom() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
    );
    if (result == true) _loadRooms();
  }

  Future<void> _deleteRoom(RoomEntity room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف "${room.title}"؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف')),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.delete("rooms/${room.id}");
      _loadRooms();
    }
  }

  Future<void> _muteRoom(RoomEntity room) async {
    final updatedRoom = RoomModel.fromEntity(
      room.copyWith(isMuted: !room.isMuted),
    );
    await ApiService.put("rooms/${room.id}", data: updatedRoom.toJson());
    _loadRooms();
  }

  Future<void> _playTapSound() async {
    await SystemSound.play(SystemSoundType.click);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("غرف الهمس"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_copy_outlined),
            tooltip: 'مجلداتي',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivateFolderScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(isGrid ? Icons.blur_circular : Icons.grid_view_rounded),
            onPressed: _toggleLayout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createRoom,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      hintText: '🔍 ابحث عن غرفة...',
                      fillColor: Colors.white10,
                      filled: true,
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final tag = categories[index];
                      final selected = tag == selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => selectedCategory = tag),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? theme.colorScheme.primary
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filteredRooms.isEmpty
                      ? const Center(
                          child: Text(
                            "لا توجد غرف بعد...",
                            style:
                                TextStyle(color: Colors.white38, fontSize: 20),
                          ),
                        )
                      : isGrid
                          ? _buildGridLayout()
                          : _buildOrbitLayout(),
                ),
              ],
            ),
    );
  }

  Widget _buildGridLayout() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemCount: filteredRooms.length,
      itemBuilder: (context, index) {
        final room = filteredRooms[index];
        return Stack(
          children: [
            _buildRoomCircle(room),
            Positioned(
              right: 0,
              top: 0,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: Colors.white70, size: 20),
                onSelected: (value) async {
                  if (value == 'delete') {
                    _deleteRoom(room);
                  } else if (value == 'edit') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditRoomScreen(
                            room: RoomModel.fromEntity(room)),
                      ),
                    );
                    if (result == true) _loadRooms();
                  } else if (value == 'mute') {
                    _muteRoom(room);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('تعديل'),
                  ),
                  PopupMenuItem(
                    value: 'mute',
                    child: Text(room.isMuted
                        ? 'إلغاء كتم التنبيهات'
                        : 'كتم التنبيهات'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('حذف'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrbitLayout() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRooms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final room = filteredRooms[index];
        final color = Color(room.color);

        return ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tileColor: Colors.white10,
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.5),
            child: Text(
              room.title.characters.first,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          title: Text(room.title, style: const TextStyle(color: Colors.white)),
          subtitle:
              Text(room.category, style: const TextStyle(color: Colors.white54)),
          trailing: room.isMuted
              ? const Icon(Icons.notifications_off, color: Colors.white54)
              : null,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.chat, arguments: room);
          },
        );
      },
    );
  }

  Widget _buildRoomCircle(RoomEntity room, {double size = 100}) {
    final color = Color(room.color);
    return GestureDetector(
      onTap: () async {
        await _playTapSound();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDetailsScreen(room: RoomModel.fromEntity(room)),
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.7), Colors.transparent],
            stops: const [0.3, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 10,
            )
          ],
        ),
        child: Center(
          child: Text(
            room.title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ),
    );
  }
}