import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/ui/dashboard/tab/search_tab.dart';
import 'package:test_app/src/ui/search/nearby_search_page.dart';
// Storage
import '../core/services/storage_service.dart';

// Auth
import '../ui/auth/login_page.dart';
import '../ui/auth/register_page.dart';
import '../ui/auth/otp_page.dart';

// Dashboard
import '../ui/dashboard/dashboard_page.dart';

// Profile

// Tuition
import '../ui/tuition/tuition_list.dart';
import '../ui/tuition/tuition_create_page.dart';
import '../ui/tuition/tuition_details_page.dart';
import '../ui/tuition/my_applications_page.dart';
import '../ui/chat/chat_room_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final storage = GetIt.instance<StorageService>();

    // ===========================================================
    // ROOT "/" — login state check ONLY here
    // ===========================================================
    if (settings.name == '/') {
      return MaterialPageRoute(
        builder: (_) => FutureBuilder(
          future: storage.getToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final token = snapshot.data;

            // NOT LOGGED IN → LOGIN PAGE
            if (token == null) return const LoginPage();

            // LOGGED IN → DASHBOARD
            return const DashboardPage();
          },
        ),
      );
    }

    // ===========================================================
    // NORMAL ROUTES
    // ===========================================================
    return MaterialPageRoute(
      builder: (_) {
        switch (settings.name) {
          // ---------------- AUTH ----------------
          case '/login':
            return const LoginPage();

          case '/register':
            return const RegisterPage();

          case '/otp':
            final args = settings.arguments as Map?;
            final email = args?['email'] ?? '';
            return OtpPage(email: email);

          // ---------------- DASHBOARD ----------------
          case '/dashboard':
            return const DashboardPage();

          // ---------------- PROFILE ----------------

          // ---------------- TUITION SYSTEM ----------------
          case '/tuition':
            return const TuitionListPage(isTeacherView: false);

          case '/tuition/teacher':
            return const TuitionListPage(isTeacherView: true);

          case '/tuition/create':
            return const TuitionCreatePage();

          case '/tuition/details':
            final post = settings.arguments as Map<String, dynamic>? ?? {};
            return TuitionDetailsPage(post: post);

          case '/tuition/applications':
            final postId = settings.arguments as String? ?? "";
            return MyApplicationsPage(postId: postId);

          case '/chat/room':
            final room = settings.arguments as Map<String, dynamic>;
            final roomId = room["_id"] ?? room["id"];
            return ChatRoomPage(roomId: roomId);

          case '/search':
            return const SearchTab();

          case '/search/nearby':
            return const NearbySearchPage();

          // ---------------- DEFAULT ----------------
          default:
            return Scaffold(
              body: Center(
                child: Text("No route defined for ${settings.name}"),
              ),
            );
        }
      },
    );
  }
}
