import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/chat_service.dart';
import 'package:test_app/src/core/services/auth_service.dart';

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  final String? partnerName;

  const ChatRoomPage({super.key, required this.roomId, this.partnerName});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final chat = GetIt.instance<ChatService>();
  final auth = GetIt.instance<AuthService>();

  bool loading = true;
  List messages = [];
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    setState(() => loading = true);
    try {
      final res = await chat.getMessages(widget.roomId);
      setState(() => messages = res);
    } catch (e) {
      print("Error loading messages: $e");
    }
    setState(() => loading = false);
  }

  Future<void> send() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    controller.clear();
    await chat.sendMessage(widget.roomId, text);
    loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.partnerName ?? "Chat")),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    reverse: true,
                    itemBuilder: (_, i) {
                      final m = messages[messages.length - 1 - i];
                      final senderIdFromMsg =
                          m["senderId"] ??
                          m["sender"]?["_id"] ??
                          m["sender"]?.toString() ??
                          "";
                      final currentUserId = auth.user?.id ?? "";
                      final isMe = senderIdFromMsg == currentUserId;

                      print(
                        "[Chat] Message: sender=$senderIdFromMsg, me=$currentUserId, isMe=$isMe",
                      );

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.blue.shade600
                                : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            m["content"] ?? m["text"] ?? "",
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // SEND BOX
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
