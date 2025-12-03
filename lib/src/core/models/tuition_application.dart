import 'tuition_post.dart';

class TuitionApplication {
  final String id;
  final String postId;
  final String teacherId;
  final String status;
  final TuitionPost? post;

  TuitionApplication({
    required this.id,
    required this.postId,
    required this.teacherId,
    required this.status,
    this.post,
  });

  factory TuitionApplication.fromJson(Map<String, dynamic> json) {
    return TuitionApplication(
      id: json["_id"] ?? "",
      postId: json["postId"] is Map
          ? json["postId"]["_id"]
          : json["postId"] ?? "",
      teacherId: json["teacherId"] ?? "",
      status: json["status"] ?? "pending",
      post: json["postId"] is Map ? TuitionPost.fromJson(json["postId"]) : null,
    );
  }
}
