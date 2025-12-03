import 'package:test_app/src/config/api_paths.dart';
import 'package:test_app/src/core/network/api_client.dart';
import 'models/tuition_post.dart';

class NearbyApi {
  final ApiClient api;

  NearbyApi({required this.api});

  /// Calls server /tuition-posts/nearby and returns typed TuitionPost list.
  Future<Map<String, dynamic>> nearby({
    required double lat,
    required double lng,
    double radiusKm = 10,
    bool withDistance = false,
    int page = 1,
    int limit = 50,
  }) async {
    final res = await api.get(
      ApiPaths.tuitionNearby,
      query: {
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radiusKm': radiusKm.toString(),
        'withDistance': withDistance ? 'true' : 'false',
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final raw = res['posts'] as List? ?? [];
    final posts = raw
        .map((e) {
          if (e is Map<String, dynamic>) return TuitionPost.fromJson(e);
          if (e is Map)
            return TuitionPost.fromJson(Map<String, dynamic>.from(e));
          return null;
        })
        .where((p) => p != null)
        .cast<TuitionPost>()
        .toList();

    return {'posts': posts, 'page': res['page'], 'perPage': res['perPage']};
  }
}
