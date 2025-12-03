class ApiPaths {
  // ---------- AUTH ----------
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String me = "/auth/me";
  static const String requestOtp = "/auth/request-otp";
  static const String verifyOtp = "/auth/verify-otp";
  static const String updateBasic = "/auth/update-basic";

  // ---------- PROFILE ----------
  static const String profileMe = "/profile/me";
  static const String profileStudent = "/profile/student";
  static const String profileTeacher = "/profile/teacher";

  // ---------- TUITION ----------
  static const String tuitionList = "/tuition-posts";
  static const String tuitionCreate = "/tuition-posts";

  static String closeTuition(String id) => "/tuition-posts/close/$id";
  static String applyTuition(String id) => "/tuition-posts/apply/$id";
  static const String myApplications = "/tuition-posts/applications/my";

  static String acceptApplication(String id) =>
      "/tuition-posts/accept/$id"; // backend not added yet

  // Server-side nearby tuition posts
  static const String tuitionNearby = "/tuition-posts/nearby";

  // ---------- MATCH ----------
  static const String myMatches = "/matches/my";

  // ---------- CHAT ----------
  static const String chatRooms = "/chat/rooms";
  static const String myChatRooms = "/chat/rooms/my";
  static String chatMessages(String id) => "/chat/rooms/$id/messages";

  // ---------- DEMO ----------
  static const String demoRequest = "/demo-sessions/request";
  static const String myDemos = "/demo-sessions/my";

  // ---------- SEARCH ----------
  static const String searchTeachers = "/search/teachers";
  static const String searchStudents = "/search/students";

  // ---------- REVIEWS ----------
  static String teacherReviews(String id) => "/reviews/teacher/$id";

  // ---------- NOTIFICATIONS ----------
  static const String myNotifications = "/notifications/my";

  // ---------- ADMIN ----------
  static const String adminStats = "/admin/stats";
  static const String adminUsers = "/admin/users";

  static String adminSuspendUser(String id) => "/admin/users/$id/suspend";
  static String adminApproveTeacher(String id) => "/admin/teachers/$id/approve";

  static String adminApproveTuition(String id) => "/admin/tuition/$id/approve";

  static String adminApplicationApprove(String id) =>
      "/admin/applications/$id/approve";

  static const String adminDemos = "/admin/demos";
  static String adminUpdateDemo(String id) => "/admin/demos/$id";
}
