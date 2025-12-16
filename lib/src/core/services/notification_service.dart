import 'package:test_app/src/config/api_paths.dart';
import 'package:test_app/src/core/network/api_client.dart';

class NotificationService {
  final ApiClient apiClient;

  NotificationService({required this.apiClient});

  Future<Map<String, dynamic>> getMyNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await apiClient.get(
      '${ApiPaths.myNotifications}?page=$page&limit=$limit',
    );
    return {
      'notifications': res['notifications'] ?? res['data'] ?? [],
      'unreadCount': res['unreadCount'] ?? 0,
      'totalCount': res['totalCount'] ?? 0,
      'page': res['page'] ?? page,
      'limit': res['limit'] ?? limit,
    };
  }

  Future<Map<String, dynamic>> markNotificationAsRead(String notificationId) async {
    final res = await apiClient.patch(
      '${ApiPaths.myNotifications}/$notificationId/read',
      {},
    );
    return res;
  }

  Future<void> deleteNotification(String notificationId) async {
    await apiClient.delete('${ApiPaths.myNotifications}/$notificationId');
  }
}
