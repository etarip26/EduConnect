import 'package:test_app/src/config/api_paths.dart';
import 'package:test_app/src/core/network/api_client.dart';
import 'package:test_app/src/core/utils/location_utils.dart';
import 'package:test_app/src/core/api_client_generated/nearby_api.dart';
import 'package:test_app/src/core/api_client_generated/models/tuition_post.dart';

class TuitionService {
  final ApiClient api;

  TuitionService({required this.api});

  /// -----------------------------------------------------------
  /// PUBLIC: GET ALL TUITION POSTS
  /// GET /tuition-posts
  /// -----------------------------------------------------------
  Future<List<dynamic>> list() async {
    final res = await api.get(ApiPaths.tuitionList);
    return res['posts'] ?? [];
  }

  /// -----------------------------------------------------------
  /// GET TUITION POSTS NEARBY
  /// Fetches all posts then filters by distance (km) from given center.
  /// This uses a simple Haversine distance computation client-side.
  /// -----------------------------------------------------------
  Future<List<dynamic>> listNearby({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) async {
    final all = await list();
    return filterByRadius(all, lat, lng, radiusKm);
  }

  /// -----------------------------------------------------------
  /// SERVER-SIDE: GET NEARBY TUITION POSTS WITH COMBINED FILTERS
  /// Calls backend `/tuition-posts/nearby` with location + content filters.
  /// Supports class level, subjects, city filters in addition to radius.
  /// -----------------------------------------------------------
  Future<List<dynamic>> listNearbyServerWithFilters({
    required double lat,
    required double lng,
    double radiusKm = 10,
    String? classLevel,
    List<String>? subjects,
    String? city,
  }) async {
    final query = {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'radiusKm': radiusKm.toString(),
    };
    if (classLevel != null && classLevel.isNotEmpty) {
      query['classLevel'] = classLevel;
    }
    if (subjects != null && subjects.isNotEmpty) {
      query['subjects'] = subjects.join(',');
    }
    if (city != null && city.isNotEmpty) {
      query['city'] = city;
    }
    final res = await api.get(ApiPaths.tuitionNearby, query: query);
    return res['posts'] ?? [];
  }

  /// Typed version using generated-like client that returns `TuitionPost` objects.
  Future<List<TuitionPost>> listNearbyTyped({
    required double lat,
    required double lng,
    double radiusKm = 10,
    bool withDistance = false,
    int page = 1,
    int limit = 50,
  }) async {
    final apiWrapper = NearbyApi(api: api);
    final response = await apiWrapper.nearby(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      withDistance: withDistance,
      page: page,
      limit: limit,
    );
    return (response['posts'] as List)
        .map((post) => TuitionPost.fromJson(post))
        .toList();
  }

  /// -----------------------------------------------------------
  /// STUDENT: CREATE POST
  /// POST /tuition-posts
  /// -----------------------------------------------------------
  Future<dynamic> create(Map<String, dynamic> body) async {
    return await api.post(ApiPaths.tuitionCreate, body);
  }

  /// -----------------------------------------------------------
  /// STUDENT: CLOSE POST
  /// PUT /tuition-posts/close/:postId
  /// -----------------------------------------------------------
  Future<void> close(String postId) async {
    await api.put(ApiPaths.closeTuition(postId), {});
  }

  /// -----------------------------------------------------------
  /// TEACHER: APPLY TO POST
  /// POST /tuition-posts/apply/:postId
  /// -----------------------------------------------------------
  Future<void> applyToPost(String postId) async {
    await api.post(ApiPaths.applyTuition(postId));
  }

  /// -----------------------------------------------------------
  /// TEACHER: MY APPLICATIONS
  /// GET /tuition-posts/applications/my
  /// -----------------------------------------------------------
  Future<List<dynamic>> myApplications() async {
    final res = await api.get(ApiPaths.myApplications);
    return res['applications'] ?? [];
  }

  /// -----------------------------------------------------------
  /// STUDENT: GET APPLICATIONS FOR A SPECIFIC POST
  /// GET /tuition-posts/:postId/applications
  /// -----------------------------------------------------------
  Future<Map<String, dynamic>> getApplications(String postId) async {
    return await api.get("/tuition-posts/$postId/applications");
  }

  /// -----------------------------------------------------------
  /// STUDENT: ACCEPT APPLICATION
  /// POST /tuition-posts/accept/:appId
  /// Returns → { matchId }
  /// -----------------------------------------------------------
  Future<Map<String, dynamic>> acceptApplication(String appId) async {
    return await api.post("/tuition-posts/accept/$appId");
  }
}
