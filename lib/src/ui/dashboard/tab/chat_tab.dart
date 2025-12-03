import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/chat_service.dart';
import 'package:test_app/src/ui/chat/chat_room_page.dart';
import 'package:test_app/src/core/widgets/app_avatar.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final chat = GetIt.instance<ChatService>();

  bool loading = true;
  List rooms = [];

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  Future<void> loadRooms() async {
    setState(() => loading = true);

    try {
      final res = await chat.getMyRooms();
      rooms = res;
    } catch (e) {
      print("Chat rooms load error: $e");
      rooms = [];
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (rooms.isEmpty) {
      return const Center(child: Text("No active chats yet"));
    }

    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (_, i) {
        final r = rooms[i];
        final partner =
            r["matchId"]?["teacherName"] ??
            r["matchId"]?["studentName"] ??
            "Partner";

        return ListTile(
          leading: AppAvatar(name: partner, radius: 20),
          title: Text(partner),
          subtitle: const Text("Tap to open chat"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatRoomPage(roomId: r["_id"])),
            );
          },
        );
      },
    );
  }
}
