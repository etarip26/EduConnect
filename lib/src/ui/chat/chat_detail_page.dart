import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/chat_service.dart';
import 'package:test_app/src/core/services/auth_service.dart';
import 'package:test_app/src/core/utils/snackbar_utils.dart';

class ChatDetailPage extends StatefulWidget {
  final String roomId;
  final String? otherUserName;
  const ChatDetailPage({super.key, required this.roomId, this.otherUserName});

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
  String? typingUserId;
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    loadMessages();
    setupLiveMessaging();
  }

  /// Setup real-time messaging with Socket.io
  void setupLiveMessaging() {
    // Connect to socket if not connected
    if (!chatService.isConnected) {
      unawaited(chatService.connectSocket());
    }

    // Join this specific chat room
    chatService.joinRoom(widget.roomId);

    // Listen for new messages
    chatService.onNewMessage = (message) {
      if (!mounted) return;
      setState(() {
        messages.add(message);
      });
      _scrollToBottom();
    };

    // Listen for typing indicators
    chatService.onTyping = (userId) {
      if (!mounted) return;
      setState(() => typingUserId = userId);
    };

    chatService.onTypingStop = (userId) {
      if (!mounted) return;
      if (typingUserId == userId) {
        setState(() => typingUserId = null);
      }
    };

    // Listen for message read status
    chatService.onMessagesRead = (roomId) {
      if (!mounted) return;
      setState(() {
        for (var msg in messages) {
          if (msg["senderId"] == auth.user?.id) {
            msg["status"] = "seen";
          }
        }
      });
    };
  }

  Future<void> loadMessages() async {
    setState(() => loading = true);
    try {
      final data = await chatService.getMessages(widget.roomId);
      setState(() => messages = data);
      _scrollToBottom();
      chatService.markMessagesRead(widget.roomId);
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

  void sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    chatService.sendTyping(widget.roomId, isTyping: false);
    try {
      chatService.sendMessageLive(widget.roomId, text);
    } catch (e) {
      print("Socket error, falling back to REST: $e");
      sendMessageRest(text);
    }
  }

  Future<void> sendMessageRest(String text) async {
    try {
      final msg = await chatService.sendMessage(widget.roomId, text);
      setState(() => messages.add(msg));
      _scrollToBottom();
    } catch (e) {
      showSnackBar(context, "Failed to send message", isError: true);
    }
  }

  void onMessageChanged(String value) {
    if (value.isNotEmpty && !isTyping) {
      chatService.sendTyping(widget.roomId, isTyping: true);
      setState(() => isTyping = true);
    } else if (value.isEmpty && isTyping) {
      chatService.sendTyping(widget.roomId, isTyping: false);
      setState(() => isTyping = false);
    }
  }

  bool isMine(dynamic msg) {
    return msg["senderId"] == auth.user?.id;
  }

  @override
  void dispose() {
    chatService.sendTyping(widget.roomId, isTyping: false);
    chatService.leaveRoom(widget.roomId);
    _messageController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName ?? "Chat"), elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (_, i) => _buildBubble(messages[i]),
                  ),
          ),
          if (typingUserId != null && typingUserId != auth.user?.id)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Text("Typing", style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 20,
                    height: 12,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                    onChanged: onMessageChanged,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.indigo,
                  ),
                  child: IconButton(
                    onPressed: sendMessage,
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(dynamic msg) {
    final mine = isMine(msg);
    final status = msg["status"] ?? "";
    final senderName = msg["senderId"] is Map
        ? msg["senderId"]["name"] ?? "Unknown"
        : "Unknown";

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: mine ? Colors.indigo : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!mine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  senderName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            Text(
              msg["text"] ?? msg["content"] ?? "",
              style: TextStyle(color: mine ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(msg["createdAt"]),
                  style: TextStyle(
                    fontSize: 12,
                    color: mine ? Colors.white70 : Colors.grey,
                  ),
                ),
                if (mine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    status == "seen"
                        ? Icons.done_all
                        : status == "delivered"
                        ? Icons.done
                        : Icons.schedule,
                    size: 12,
                    color: mine ? Colors.white70 : Colors.grey,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return "";
    try {
      final dt = DateTime.parse(timestamp.toString());
      return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }
}
