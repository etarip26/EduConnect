import 'tuition_post.dart';

class MatchModel {
  final String id;
  final String tuitionId;
  final String studentId;
  final String teacherId;
  final String status;
  final TuitionPost? tuition;

  MatchModel({
    required this.id,
    required this.tuitionId,
    required this.studentId,
    required this.teacherId,
    required this.status,
    this.tuition,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json["_id"] ?? "",
      tuitionId: json["tuitionId"] is Map
          ? json["tuitionId"]["_id"]
          : json["tuitionId"] ?? "",
      studentId: json["studentId"] ?? "",
      teacherId: json["teacherId"] ?? "",
      status: json["status"] ?? "active",
      tuition: json["tuitionId"] is Map
          ? TuitionPost.fromJson(json["tuitionId"])
          : null,
    );
  }
}
