import 'package:test_app/src/core/network/api_client.dart';

class TopTeachersService {
  final ApiClient apiClient;

  TopTeachersService({required this.apiClient});

  /// Fetch top rated teachers
  Future<List<Map<String, dynamic>>> getTopTeachers({int limit = 5}) async {
    try {
      final res = await apiClient.get('/profile/top-teachers?limit=$limit');

      if (res['teachers'] != null) {
        return List<Map<String, dynamic>>.from(res['teachers']);
      }

      return [];
    } catch (e) {
      print("TopTeachersService - getTopTeachers error: $e");
      rethrow;
    }
  }
}
