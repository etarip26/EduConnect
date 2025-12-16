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
    try {
      final res = await api.get(ApiPaths.adminStats);
      return res['stats'] ?? res ?? {};
    } catch (e) {
      print("Error fetching admin stats: $e");
      return {};
    }
  }

  // ---------------------------------------------------------
  // GET ALL USERS
  // GET /api/admin/users
  // ---------------------------------------------------------
  Future<List<dynamic>> getUsers() async {
    try {
      final res = await api.get(ApiPaths.adminUsers);
      // Backend returns { success: true, data: users, pagination: {...} } or { users: [...] }
      return res['data'] ?? res['users'] ?? [];
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
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
  // APPROVE/REJECT TUITION APPLICATION
  // PATCH /api/admin/applications/:id/approve
  // body: { action: 'approve'|'reject', notes?: string }
  // ---------------------------------------------------------
  Future<void> approveApplication(
    String appId, {
    String action = 'approve',
    String? notes,
  }) async {
    final body = {'action': action};
    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }
    await api.patch(ApiPaths.adminApplicationApprove(appId), body);
  }

  // ---------------------------------------------------------
  // GET ALL PENDING TEACHERS (custom helper)
  // NOTE: Your backend does NOT provide this directly,
  // so we fetch all users + filter based on TeacherProfile existence.
  //
  // If backend adds an endpoint later, we replace this easily.
  // ---------------------------------------------------------
  Future<List<dynamic>> getTeachersPending() async {
    try {
      final res = await api.get(ApiPaths.adminUsers);
      final users = res['data'] ?? res['users'] ?? [];

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
        return u["role"] == "teacher" &&
            (u["isVerified"] == false || u["isProfileApproved"] == false);
      }).toList();
    } catch (e) {
      print("Error fetching pending teachers: $e");
      return [];
    }
  }

  // ---------------------------------------------------------
  // GET ALL PENDING TUITIONS (ADMIN ENDPOINT)
  // GET /api/admin/tuition/pending
  //
  // Backend returns pending tuition posts for admin review.
  // ---------------------------------------------------------
  Future<List<dynamic>> getTuitionsPending() async {
    try {
      final res = await api.get(ApiPaths.adminPendingTuitions);
      final posts = res['data'] ?? res['posts'] ?? [];
      print("Fetched ${posts.length} pending tuitions");
      return posts;
    } catch (e) {
      print("Error fetching pending tuitions: $e");
      return [];
    }
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
    final res = await api.post('/admin/users/admin/create', {
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
    final res = await api.patch('/admin/users/$userId/role', {'role': role});
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
    final res = await api.get('/admin/dashboard/stats');
    return res['data'] ?? res;
  }

  /// Send announcement to all users
  Future<Map<String, dynamic>> sendAnnouncement({
    required String title,
    required String content,
    String? priority,
  }) async {
    final res = await api.post('/admin/announcements', {
      'title': title,
      'description': content,
      'priority': priority ?? 'medium',
    });
    return res;
  }

  /// Send message to specific user
  Future<Map<String, dynamic>> sendMessageToUser({
    required String userId,
    required String message,
  }) async {
    final res = await api.post('/admin/messages/send', {
      'recipientId': userId,
      'message': message,
    });
    return res;
  }

  /// Get all users with full details
  Future<List<dynamic>> getAllUsers({
    int page = 1,
    int limit = 50,
    String? role,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (role != null) queryParams['role'] = role;
    if (search != null) queryParams['search'] = search;

    final res = await api.get('/admin/users', query: queryParams);
    return res['data'] ?? res['users'] ?? [];
  }

  /// Enable/disable parent control for a student
  Future<Map<String, dynamic>> toggleParentControl({
    required String studentId,
    required bool enabled,
  }) async {
    final res = await api.patch('/admin/students/$studentId/parent-control', {
      'enabled': enabled,
    });
    return res;
  }

  /// Approve user profile
  Future<Map<String, dynamic>> approveUserProfile(String userId) async {
    final res = await api.patch('/admin/profiles/$userId/approve', {});
    return res;
  }

  /// Reject user profile
  Future<Map<String, dynamic>> rejectUserProfile(
    String userId,
    String reason,
  ) async {
    final res = await api.patch('/admin/profiles/$userId/reject', {
      'reason': reason,
    });
    return res;
  }

  /// Get pending users for approval
  Future<List<dynamic>> getPendingUsers() async {
    final res = await api.get('/admin/profiles/pending');
    return res['data'] ?? res['users'] ?? [];
  }

  /// Get all users separated by approval status
  Future<Map<String, List<dynamic>>> getUsersByApprovalStatus() async {
    final allUsers = await getUsers();
    final pendingUsers = allUsers
        .where((u) => u['isProfileApproved'] != true)
        .toList();
    final approvedUsers = allUsers
        .where((u) => u['isProfileApproved'] == true)
        .toList();

    return {
      'pending': pendingUsers,
      'approved': approvedUsers,
      'all': allUsers,
    };
  }

  // ---------------------------------------------------------
  // GET PENDING TUITION APPLICATIONS
  // GET /api/admin/applications/pending
  // ---------------------------------------------------------
  Future<List<dynamic>> getApplicationsPending() async {
    final res = await api.get('/api/admin/applications/pending');
    return res['applications'] ?? [];
  }
}
