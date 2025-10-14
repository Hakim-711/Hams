import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  late IO.Socket socket;

  SocketService._internal();

  void connect() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print("🟢 Connected to WebSocket");
    });

    socket.onDisconnect((_) {
      print("🔴 Disconnected from WebSocket");
    });
  }

  void joinRoom(String roomId) {
    socket.emit('joinRoom', roomId);
    print("🏠 Joined room $roomId");
  }

  void sendMessage(Map<String, dynamic> messageData) {
    socket.emit('sendMessage', messageData);
  }

  void onNewMessage(Function(dynamic) callback) {
    socket.on('newMessage', callback);
  }

  void emitMessageRead(String roomId, String messageId, String readerId) {
    socket.emit('messageRead', {
      'roomId': roomId,
      'messageId': messageId,
      'readerId': readerId,
    });
  }

  void onMessageSeen(Function(dynamic) callback) {
    socket.on('messageSeen', callback);
  }

  void disconnect() {
    socket.disconnect();
  }
}
