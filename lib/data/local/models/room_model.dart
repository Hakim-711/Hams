// 📁 lib/data/local/models/room_model.dart
import 'package:hams/domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    super.id,
    required super.title,
    required super.category,
    required super.color,
    required super.participants,
    super.isMuted,
    super.isPinned,
    super.lastMessage,
    super.unreadCount,
    required super.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      color: json['color'],
      participants: List<String>.from(json['participants'] ?? []),
      isMuted: json['isMuted'] == true || json['isMuted'] == 1,
      isPinned: json['isPinned'] == true || json['isPinned'] == 1,
      lastMessage: json['lastMessage'],
      unreadCount: json['unreadCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'color': color,
      'participants': participants,
      'isMuted': isMuted,
      'isPinned': isPinned,
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RoomModel.fromEntity(RoomEntity entity) {
    return RoomModel(
      id: entity.id,
      title: entity.title,
      category: entity.category,
      color: entity.color,
      participants: entity.participants,
      isMuted: entity.isMuted,
      isPinned: entity.isPinned,
      lastMessage: entity.lastMessage,
      unreadCount: entity.unreadCount,
      createdAt: entity.createdAt,
    );
  }

  RoomEntity toEntity() => RoomEntity(
        id: id,
        title: title,
        category: category,
        color: color,
        participants: participants,
        isMuted: isMuted,
        isPinned: isPinned,
        lastMessage: lastMessage,
        unreadCount: unreadCount,
        createdAt: createdAt,
      );
}