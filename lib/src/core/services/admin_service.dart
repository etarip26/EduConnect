import 'package:test_app/src/config/api_paths.dart';
import 'package:test_app/src/core/network/api_client.dart';

class AdminService {
  final ApiClient api;

  AdminService(this.api);

  // ---------------------------------------------------------
  // GET ADMIN STATS
  // GET /api/admin/stats
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> getStats() async {
    final res = await api.get(ApiPaths.adminStats);
    return res['stats'] ?? {};
  }

  // ---------------------------------------------------------
  // GET ALL USERS
  // GET /api/admin/users
  // ---------------------------------------------------------
  Future<List<dynamic>> getUsers() async {
    final res = await api.get(ApiPaths.adminUsers);
    return res['users'] ?? [];
  }

  // ---------------------------------------------------------
  // SUSPEND / UNSUSPEND USER
  // PATCH /api/admin/users/:userId/suspend
  // ---------------------------------------------------------
  Future<void> toggleSuspend(String userId) async {
    await api.patch(ApiPaths.adminSuspendUser(userId), {});
  }

  // ---------------------------------------------------------
  // APPROVE TEACHER PROFILE
  // PATCH /api/admin/teachers/:teacherId/approve
  // ---------------------------------------------------------
  Future<void> approveTeacher(String teacherUserId) async {
    await api.patch(ApiPaths.adminApproveTeacher(teacherUserId), {});
  }

  // ---------------------------------------------------------
  // APPROVE TUITION
  // PATCH /api/admin/tuition/:id/approve
  // ---------------------------------------------------------
  Future<void> approveTuition(String tuitionId) async {
    await api.patch(ApiPaths.adminApproveTuition(tuitionId), {});
  }

  // ---------------------------------------------------------
  // APPROVE TUITION APPLICATION
  // PATCH /api/admin/applications/:id/approve
  // ---------------------------------------------------------
  Future<void> approveApplication(String appId) async {
    await api.patch(ApiPaths.adminApplicationApprove(appId), {});
  }

  // ---------------------------------------------------------
  // GET ALL PENDING TEACHERS (custom helper)
  // NOTE: Your backend does NOT provide this directly,
  // so we fetch all users + filter based on TeacherProfile existence.
  //
  // If backend adds an endpoint later, we replace this easily.
  // ---------------------------------------------------------
  Future<List<dynamic>> getTeachersPending() async {
    final res = await api.get(ApiPaths.adminUsers);

    final users = res['users'] ?? [];

    // BACKEND: A teacher profile waiting approval has:
    // teacherProfile.isVerified == false
    //
    // But your /users endpoint does NOT return teacher profile info.
    //
    // Therefore:
    // For now, we load ALL TEACHER USERS who are NOT verified
    // and backend must expand /admin/users response to include profile.
    //
    // Temporary fallback until backend update:
    return users.where((u) {
      return u["role"] == "teacher" && (u["isVerified"] == false);
    }).toList();
  }

  // ---------------------------------------------------------
  // GET ALL PENDING TUITIONS
  // GET /api/tuition-posts
  //
  // Backend returns all posts to public.
  // We filter pending ones.
  // ---------------------------------------------------------
  Future<List<dynamic>> getTuitionsPending() async {
    final res = await api.get("/tuition-posts");
    final posts = res['posts'] ?? res['data'] ?? [];

    return posts.where((p) => p["status"] == "pending").toList();
  }

  // ---------------------------------------------------------
  // GET ALL DEMO SESSIONS (for admin panel)
  // GET /api/admin/demos
  // ---------------------------------------------------------
  Future<List<dynamic>> getDemos() async {
    final res = await api.get(ApiPaths.adminDemos);
    return res['sessions'] ?? [];
  }

  // ---------------------------------------------------------
  // UPDATE DEMO SESSION STATUS
  // PATCH /api/admin/demos/:id
  // body: { status }
  // ---------------------------------------------------------
  Future<void> updateDemo(String sessionId, String status) async {
    await api.patch(ApiPaths.adminUpdateDemo(sessionId), {"status": status});
  }
}
