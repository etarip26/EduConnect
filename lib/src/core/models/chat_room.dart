class ChatRoom {
  final String id;
  final String matchId;
  final String studentId;
  final String teacherId;
  final DateTime? lastMessageAt;

  ChatRoom({
    required this.id,
    required this.matchId,
    required this.studentId,
    required this.teacherId,
    this.lastMessageAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json["_id"] ?? "",
      matchId: json["matchId"] ?? "",
      studentId: json["studentId"] ?? "",
      teacherId: json["teacherId"] ?? "",
      lastMessageAt: json["lastMessageAt"] != null
          ? DateTime.parse(json["lastMessageAt"])
          : null,
    );
  }
}
