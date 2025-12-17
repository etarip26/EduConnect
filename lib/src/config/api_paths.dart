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
  static const String tuitionList = "/tuition/posts";
  static const String tuitionCreate = "/tuition/posts";

  static String closeTuition(String id) => "/tuition/posts/close/$id";
  static String applyTuition(String id) => "/tuition/posts/$id/apply";
  static const String myApplications = "/tuition/applications/my";

  static String acceptApplication(String id) =>
      "/tuition/applications/accept/$id";

  // Server-side nearby tuition posts
  static const String tuitionNearby = "/tuition/posts/nearby";

  // ---------- MATCH ----------
  static const String myMatches = "/matches/my";

  // ---------- CHAT ----------
  static const String chatRooms = "/chat/rooms";
  static const String myChatRooms = "/chat/rooms/my";
  static String chatMessages(String id) => "/chat/rooms/$id/messages";

  // ---------- DEMO ----------
  static const String demoRequest = "/demo/request";
  static const String myDemos = "/demo/my";

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
  static String adminApproveTeacher(String id) => "/admin/profiles/$id/approve";

  static const String adminPendingTuitions = "/admin/tuition-posts/pending";
  static const String adminApplicationsPending = "/admin/applications/pending";

  static String adminApproveTuition(String id) =>
      "/admin/tuition-posts/$id/approve";

  static String adminApplicationApprove(String id) =>
      "/admin/applications/$id/approve";

  static const String adminDemos = "/admin/demos";
  static String adminUpdateDemo(String id) => "/admin/demos/$id";

  // ---------- ANNOUNCEMENTS ----------
  static const String announcementsActive = "/announcements/active";
}
