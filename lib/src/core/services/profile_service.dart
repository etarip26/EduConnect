import 'package:test_app/src/core/network/api_client.dart';
import 'package:test_app/src/config/api_paths.dart';

class ProfileService {
  final ApiClient api;
  ProfileService(this.api);

  Future<Map<String, dynamic>> getMyProfile() async {
    return await api.get(ApiPaths.profileMe);
  }

  Future<void> updateStudentProfile(Map<String, dynamic> body) async {
    await api.post(ApiPaths.profileStudent, body);
  }

  Future<void> updateTeacherProfile(Map<String, dynamic> body) async {
    await api.post(ApiPaths.profileTeacher, body);
  }

  Future<void> updateUserBasic({
    required String name,
    required String phone,
  }) async {
    await api.put(ApiPaths.updateBasic, {'name': name, 'phone': phone});
  }

  Future<void> updateTeacherNIDImage({required String nidCardImageUrl}) async {
    await api.post(ApiPaths.profileTeacher, {
      'nidCardImageUrl': nidCardImageUrl,
    });
  }
}
