import 'package:test_app/src/core/network/api_client.dart';
import 'package:test_app/src/config/api_paths.dart';

class ChatService {
  final ApiClient api;
  ChatService({required this.api});

  Future<List<dynamic>> getMyRooms() async {
    final res = await api.get(ApiPaths.myChatRooms);
    return res["rooms"] ?? [];
  }

  Future<List<dynamic>> getMessages(String roomId) async {
    final res = await api.get(ApiPaths.chatMessages(roomId));
    return res["messages"] ?? [];
  }

  Future<Map<String, dynamic>> createOrGetRoom(String matchId) async {
    final res = await api.post(ApiPaths.chatRooms, {"matchId": matchId});
    return res["room"] ?? {};
  }

  Future<Map<String, dynamic>> sendMessage(String roomId, String text) async {
    final res = await api.post(ApiPaths.chatMessages(roomId), {
      "content": text,
    });
    return res["message"] ?? {};
  }
}
