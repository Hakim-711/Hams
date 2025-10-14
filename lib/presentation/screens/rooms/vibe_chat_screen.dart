import 'package:flutter/material.dart';

class VibeChatScreen extends StatefulWidget {
  final String roomName;
  final Color themeColor;

  const VibeChatScreen({
    super.key,
    required this.roomName,
    required this.themeColor,
  });

  @override
  State<VibeChatScreen> createState() => _VibeChatScreenState();
}

class _VibeChatScreenState extends State<VibeChatScreen>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> messages = [
    {"text": "مرحبًا 👋", "fromMe": false},
    {"text": "أهلًا! كيفك؟", "fromMe": true},
    {"text": "تمام الحمدلله، وانت؟", "fromMe": false},
    {"text": "كل شيء على ما يرام 💜", "fromMe": true},
  ];

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"text": text, "fromMe": true});
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.roomName),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // خلفية متدرجة حسب الغرفة
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.themeColor.withOpacity(0.2), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // الرسائل
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  return _buildBubble(message["text"], message["fromMe"]);
                },
              ),
            ),
          ),

          // حقل كتابة
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "اكتب همستك...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool fromMe) {
    final alignment = fromMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = fromMe
        ? widget.themeColor.withOpacity(0.25)
        : Colors.white.withOpacity(0.08);

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
