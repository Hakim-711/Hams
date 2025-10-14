import 'package:equatable/equatable.dart';

class RoomEntity extends Equatable {
  final int? id;
  final String title;
  final String category;
  final int color;
  final List<String> participants;
  final bool isMuted;
  final bool isPinned;
  final String? lastMessage;
  final int unreadCount;
  final DateTime createdAt;

  const RoomEntity({
    this.id,
    required this.title,
    required this.category,
    required this.color,
    required this.participants,
    this.isMuted = false,
    this.isPinned = false,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
  });

  RoomEntity copyWith({
    int? id,
    String? title,
    String? category,
    int? color,
    List<String>? participants,
    bool? isMuted,
    bool? isPinned,
    String? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      color: color ?? this.color,
      participants: participants ?? this.participants,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        color,
        participants,
        isMuted,
        isPinned,
        lastMessage,
        unreadCount,
        createdAt,
      ];
}
