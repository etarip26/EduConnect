import 'package:test_app/src/core/services/storage_service.dart';

class RouteGuard {
  static Future<String> initialRoute(StorageService storage) async {
    final token = await storage.getToken();
    return (token != null && token.isNotEmpty) ? '/dashboard' : '/login';
  }
}
