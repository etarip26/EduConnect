import 'package:test_app/src/config/api_paths.dart';
import 'package:test_app/src/core/network/api_client.dart';

class DemoService {
  final ApiClient apiClient;

  DemoService({required this.apiClient});

  Future<void> requestDemo(String matchId) async {
    await apiClient.post(ApiPaths.demoRequest, {'matchId': matchId});
  }

  Future<List<Map<String, dynamic>>> getMyDemos() async {
    final res = await apiClient.get(ApiPaths.myDemos);
    final list = res['demos'] ?? res['data'];
    if (list is List) {
      return List<Map<String, dynamic>>.from(
        list.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }
    return [];
  }
}
