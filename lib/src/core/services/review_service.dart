import 'package:test_app/src/config/api_paths.dart';
import 'package:test_app/src/core/network/api_client.dart';

class ReviewService {
  final ApiClient apiClient;

  ReviewService({required this.apiClient});

  Future<void> addTeacherReview({
    required String teacherId,
    required int rating,
    required String comment,
  }) async {
    await apiClient.post(ApiPaths.teacherReviews(teacherId), {
      'rating': rating,
      'comment': comment,
    });
  }

  Future<List<Map<String, dynamic>>> getTeacherReviews(String teacherId) async {
    final res = await apiClient.get(ApiPaths.teacherReviews(teacherId));
    final list = res['reviews'] ?? res['data'];
    if (list is List) {
      return List<Map<String, dynamic>>.from(
        list.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }
    return [];
  }
}
