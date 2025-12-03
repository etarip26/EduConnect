import 'package:test_app/src/config/api_paths.dart';
import 'package:test_app/src/core/network/api_client.dart';

class NotificationService {
  final ApiClient apiClient;

  NotificationService({required this.apiClient});

  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    final res = await apiClient.get(ApiPaths.myNotifications);
    final list = res['notifications'] ?? res['data'];
    if (list is List) {
      return List<Map<String, dynamic>>.from(
        list.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }
    return [];
  }
}
