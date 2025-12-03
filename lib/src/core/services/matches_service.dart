import 'package:test_app/src/config/api_paths.dart';
import 'package:test_app/src/core/network/api_client.dart';

class MatchesService {
  final ApiClient apiClient;

  MatchesService({required this.apiClient});

  Future<List<Map<String, dynamic>>> getMyMatches() async {
    final res = await apiClient.get(ApiPaths.myMatches);
    final list = res['matches'] ?? res['data'];
    if (list is List) {
      return List<Map<String, dynamic>>.from(
        list.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }
    return [];
  }
}
