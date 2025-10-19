// 📁 lib/presentation/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:hams/core/network/api_service.dart';
import 'package:hams/core/network/socket_service.dart';
import 'package:hams/core/utils/encryption_helper.dart';
import 'package:hams/data/local/models/message_model.dart';
import 'package:hams/data/local/models/room_model.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:hams/core/storage/session_manager.dart';

class ChatScreen extends StatefulWidget {
  final RoomModel room;
  const ChatScreen({super.key, required this.room});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> messages = [];
  MessageModel? _replyToMessage;
  String? userId;
  bool isLoading = true;

  late final SocketService socket;

  @override
  void initState() {
    super.initState();
    socket = SocketService();
    socket.connect();
    socket.joinRoom(widget.room.id.toString());

    socket.onNewMessage((data) {
      setState(() {
        messages.add(MessageModel.fromJson(data));
      });
      _scrollToBottom();
    });

    socket.onMessageSeen((data) {
      final String seenMessageId = data['messageId'];

      setState(() {
        messages = messages.map((msg) {
          if (msg.id == seenMessageId && msg.senderId == userId) {
            return msg.copyWith(isRead: true, readAt: DateTime.now());
          }
          return msg;
        }).toList();
      });
    });

    _initChat();
  }

  Future<void> _initChat() async {
    userId = await SessionManager.getUserId();
    await _loadMessages();
    await _markMessagesAsRead();
    setState(() => isLoading = false);
  }

  Future<void> _loadMessages() async {
    try {
      final result =
          await ApiService.getList('messages/room/${widget.room.id}');
      final loaded = result.map((e) => MessageModel.fromJson(e)).toList();
      setState(() => messages = loaded);
      _scrollToBottom();
    } catch (e) {
      debugPrint('⚠️ Failed to load messages: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    final plainText = _controller.text.trim();
    if (plainText.isEmpty || userId == null) return;

    final encryptedText = EncryptionHelper.encrypt(plainText);
    final message = MessageModel(
      id: const Uuid().v4(),
      roomId: widget.room.id.toString(),
      senderId: userId!,
      content: encryptedText,
      isEncrypted: true,
      sentAt: DateTime.now(),
      isSelfDestruct: true,
      isRead: false,
      replyTo: _replyToMessage?.id,
      readAt: null,
    );

    _controller.clear();
    setState(() => _replyToMessage = null);
    _addMessageLocally(message);

    // إرسال إلى السيرفر (REST)
    await ApiService.post('messages', data: message.toJson());

    // إرسال WebSocket
    socket.sendMessage(message.toJson());
  }

  void _addMessageLocally(MessageModel msg) {
    setState(() {
      messages.add(msg);
    });
    _scrollToBottom();
  }

  Future<void> _markMessagesAsRead() async {
    if (userId == null) return;

    // WebSocket لتحديث الطرف الآخر
    for (var msg in messages) {
      if (!msg.isRead && msg.senderId != userId) {
        socket.emitMessageRead(widget.room.id.toString(), msg.id, userId!);
      }
    }

    // تحديث السيرفر
    await ApiService.post('messages/mark-read', data: {
      'roomId': widget.room.id.toString(),
      'userId': userId,
    });
  }

  Future<void> _handleSelfDestruct() async {
    if (userId == null) return;
    await ApiService.post('messages/delete-self-destruct', data: {
      'roomId': widget.room.id.toString(),
      'userId': userId,
    });
  }

  @override
  void dispose() {
    _handleSelfDestruct();
    super.dispose();
  }

  String _decryptContent(MessageModel msg) {
    if (msg.isEncrypted) {
      try {
        return EncryptionHelper.decrypt(msg.content);
      } catch (e) {
        return '[❌ فشل التشفير]';
      }
    }
    return msg.content;
  }

  Widget _buildReplyBanner() {
    if (_replyToMessage == null) return const SizedBox();
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _decryptContent(_replyToMessage!),
              style: const TextStyle(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54, size: 18),
            onPressed: () => setState(() => _replyToMessage = null),
          )
        ],
      ),
    );
  }

  Widget _buildMessageTile(MessageModel msg) {
    final content = _decryptContent(msg);
    final isMine = msg.senderId == userId;

    final replyMsg = msg.replyTo != null
        ? messages.firstWhere((m) => m.id == msg.replyTo,
            orElse: () => MessageModel.placeholder())
        : null;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if ((isMine && details.primaryVelocity! < -50) ||
            (!isMine && details.primaryVelocity! > 50)) {
          setState(() => _replyToMessage = msg);
        }
      },
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (replyMsg != null)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _decryptContent(replyMsg),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMine ? Colors.blue.withOpacity(0.8) : Colors.white12,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(content, style: const TextStyle(color: Colors.white)),
          ),
          Text(
            DateFormat('hh:mm a').format(msg.sentAt) +
                (isMine && msg.isRead ? ' ✅' : ''),
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: Text(widget.room.title),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        _buildMessageTile(messages[index]),
                  ),
          ),
          _buildReplyBanner(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
