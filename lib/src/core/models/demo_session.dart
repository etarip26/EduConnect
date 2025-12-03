class DemoSession {
  final String id;
  final String matchId;
  final String studentId;
  final String teacherId;
  final String status;
  final DateTime? scheduledAt;

  DemoSession({
    required this.id,
    required this.matchId,
    required this.studentId,
    required this.teacherId,
    required this.status,
    required this.scheduledAt,
  });

  factory DemoSession.fromJson(Map<String, dynamic> json) {
    return DemoSession(
      id: json["_id"] ?? "",
      matchId: json["matchId"] ?? "",
      studentId: json["studentId"] ?? "",
      teacherId: json["teacherId"] ?? "",
      status: json["status"] ?? "",
      scheduledAt: json["scheduledAt"] != null
          ? DateTime.parse(json["scheduledAt"])
          : null,
    );
  }
}
