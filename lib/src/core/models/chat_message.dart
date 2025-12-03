class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final String status;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.status,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json["_id"] ?? "",
      roomId: json["roomId"] ?? "",
      senderId: json["senderId"] ?? "",
      content: json["content"] ?? "",
      status: json["status"] ?? "sent",
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}
