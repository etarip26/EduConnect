import 'package:get_it/get_it.dart';
import 'package:test_app/src/config/api_paths.dart';
import 'package:test_app/src/core/network/api_client.dart';
import 'package:test_app/src/core/services/auth_service.dart';

class AdminService {
  final ApiClient api;
  late final AuthService _authService;

  AdminService(this.api) {
    _authService = GetIt.I<AuthService>();
  }

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

  // ---------------------------------------------------------
  // ROLE-BASED VERIFICATION METHODS
  // ---------------------------------------------------------

  /// Check if current user is an admin
  bool isAdmin() {
    return _authService.user?.role == 'admin';
  }

  /// Check if current user has specific role
  bool hasRole(String role) {
    return _authService.user?.role == role;
  }

  /// Get current user role
  String? getUserRole() {
    return _authService.user?.role;
  }

  /// Check if user is admin or teacher
  bool isAdminOrTeacher() {
    final role = _authService.user?.role;
    return role == 'admin' || role == 'teacher';
  }

  /// Check if user is admin or student
  bool isAdminOrStudent() {
    final role = _authService.user?.role;
    return role == 'admin' || role == 'student';
  }

  /// Create new admin (admin only)
  Future<Map<String, dynamic>> createAdmin({
    required String email,
    required String tempPassword,
    String? name,
    String? phone,
  }) async {
    final res = await api.post('/api/admin/users/admin/create', {
      'email': email,
      'tempPassword': tempPassword,
      'name': name,
      'phone': phone,
    });
    return res;
  }

  /// Update user role (admin only)
  Future<Map<String, dynamic>> updateUserRole(
    String userId,
    String role,
  ) async {
    final res = await api.patch('/api/admin/users/$userId/role', {
      'role': role,
    });
    return res;
  }

  /// List users with filtering and pagination
  Future<Map<String, dynamic>> listUsers({
    String? role,
    String? status,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (role != null) queryParams['role'] = role;
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;

    final res = await api.get('/api/admin/users', query: queryParams);
    return res;
  }

  /// Get enhanced dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final res = await api.get('/api/admin/dashboard/stats');
    return res['data'] ?? res;
  }
}
