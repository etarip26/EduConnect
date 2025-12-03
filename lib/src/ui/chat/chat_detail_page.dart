import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/chat_service.dart';
import 'package:test_app/src/core/services/auth_service.dart';
import 'package:test_app/src/core/utils/snackbar_utils.dart';

class ChatDetailPage extends StatefulWidget {
  final String roomId;
  const ChatDetailPage({super.key, required this.roomId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final chatService = GetIt.instance<ChatService>();
  final auth = GetIt.instance<AuthService>();

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scroll = ScrollController();

  List messages = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    setState(() => loading = true);

    try {
      final data = await chatService.getMessages(widget.roomId);
      setState(() => messages = data);
      _scrollToBottom();
    } catch (e) {
      print("ERROR LOADING MESSAGES: $e");
    }

    setState(() => loading = false);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      final msg = await chatService.sendMessage(widget.roomId, text);

      setState(() => messages.add(msg));
      _scrollToBottom();
    } catch (e) {
      showSnackBar(context, "Failed to send message", isError: true);
    }
  }

  bool isMine(msg) {
    return msg["senderId"] == auth.user?.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          // ===========================
          // MESSAGES LIST
          // ===========================
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg = messages[i];
                      return _buildBubble(msg);
                    },
                  ),
          ),

          // ===========================
          // INPUT BAR
          // ===========================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: const Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Message...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: sendMessage,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.indigo,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================
  // CHAT BUBBLE
  // ===========================
  Widget _buildBubble(Map msg) {
    final mine = isMine(msg);
    final text = msg["content"] ?? "";

    return Container(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: mine ? Colors.indigo : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: mine
                ? const Radius.circular(20)
                : const Radius.circular(0),
            bottomRight: mine
                ? const Radius.circular(0)
                : const Radius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: mine ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
