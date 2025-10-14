class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final bool isEncrypted;
  final DateTime sentAt;
  final bool isSelfDestruct;
  final bool isRead;
  final String? replyTo; // ✅ جديد
  final DateTime? readAt; // ✅ جديد

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.isEncrypted,
    required this.sentAt,
    required this.isSelfDestruct,
    required this.isRead,
    this.replyTo,
    this.readAt,
  });
  factory MessageModel.placeholder() => MessageModel(
        id: '',
        roomId: '',
        senderId: '',
        content: '[الرسالة غير متوفرة]',
        isEncrypted: false,
        sentAt: DateTime.now(),
        isSelfDestruct: false,
        isRead: true,
        replyTo: null,
        readAt: null,
      );
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      roomId: json['roomId'],
      senderId: json['senderId'],
      content: json['content'],
      isEncrypted: json['isEncrypted'],
      sentAt: DateTime.parse(json['sentAt']),
      isSelfDestruct: json['isSelfDestruct'],
      isRead: json['isRead'],
      replyTo: json['replyTo'],
      readAt:
          json['readAt'] != null ? DateTime.parse(json['readAt']) : null, // ✅
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'content': content,
      'isEncrypted': isEncrypted,
      'sentAt': sentAt.toIso8601String(),
      'isSelfDestruct': isSelfDestruct,
      'isRead': isRead,
      'replyTo': replyTo,
      'readAt': readAt?.toIso8601String(), // ✅
    };
  }

  MessageModel copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? content,
    bool? isEncrypted,
    DateTime? sentAt,
    bool? isSelfDestruct,
    bool? isRead,
    String? replyTo,
    DateTime? readAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      sentAt: sentAt ?? this.sentAt,
      isSelfDestruct: isSelfDestruct ?? this.isSelfDestruct,
      isRead: isRead ?? this.isRead,
      replyTo: replyTo ?? this.replyTo,
      readAt: readAt ?? this.readAt, // ✅
    );
  }
}
