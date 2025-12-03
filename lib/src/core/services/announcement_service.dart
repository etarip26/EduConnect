import 'package:test_app/src/core/network/api_client.dart';

class AnnouncementService {
  final ApiClient apiClient;

  AnnouncementService({required this.apiClient});

  /// Fetch active announcements for notice board
  Future<List<Map<String, dynamic>>> getActiveAnnouncements() async {
    try {
      final res = await apiClient.get('/announcements/active');

      if (res['announcements'] != null) {
        return List<Map<String, dynamic>>.from(res['announcements']);
      }

      return [];
    } catch (e) {
      print("AnnouncementService - getActiveAnnouncements error: $e");
      rethrow;
    }
  }
}
