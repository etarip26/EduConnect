import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/tuition_service.dart';
import '../../../core/widgets/app_avatar.dart';
import '../widgets/notice_board.dart';
import '../widgets/top_teachers.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final auth = GetIt.instance<AuthService>();
  final tuitionService = GetIt.instance<TuitionService>();

  bool loading = true;
  List<Map<String, dynamic>> featured = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final list = await tuitionService.list(); // FIXED METHOD NAME
      featured = List<Map<String, dynamic>>.from(list).take(5).toList();
    } catch (e) {
      print("HomeTab load error: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(user?.name ?? "Welcome!"),

                    const SizedBox(height: 24),
                    _quickActions(context),

                    const SizedBox(height: 32),
                    const NoticeBoard(),

                    const SizedBox(height: 32),
                    const TopTeachers(),

                    const SizedBox(height: 32),
                    const Text(
                      "Featured Tuitions",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (featured.isEmpty)
                      _emptyPlaceholder()
                    else
                      Column(
                        children: featured
                            .map((p) => _tuitionCard(context, p))
                            .toList(),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  // -------------------------------------------------------------
  // HEADER / GREETING
  // -------------------------------------------------------------
  Widget _header(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A6CF7), Color(0xFF6C8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          AppAvatar(name: name, radius: 28),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              "Hello, $name 👋",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // QUICK ACTION BUTTONS
  // -------------------------------------------------------------
  Widget _quickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.search,
            label: "Search",
            color: Colors.indigo,
            onTap: () => Navigator.pushNamed(context, "/search"),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _actionButton(
            icon: Icons.book,
            label: "My Tuitions",
            color: Colors.green,
            onTap: () => Navigator.pushNamed(context, "/tuition/teacher"),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((0.35 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TUITION CARD
  // -------------------------------------------------------------
  Widget _tuitionCard(BuildContext context, Map<String, dynamic> p) {
    final subjects = (p["subjects"] as List?)?.join(", ") ?? "No subjects";
    final classLevel = p["classLevel"] ?? "Unknown";
    final city = p["location"]?["city"] ?? "Unknown";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subjects,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "$classLevel • $city",
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pushNamed(
              context,
              "/tuition/details",
              arguments: p, // FIXED
            ),
            child: const Text("View Details"),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // EMPTY PLACEHOLDER
  // -------------------------------------------------------------
  Widget _emptyPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFEEF1FF),
      ),
      child: Column(
        children: const [
          Icon(Icons.hourglass_empty, size: 50, color: Colors.indigo),
          SizedBox(height: 12),
          Text(
            "No featured tuitions available right now.",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
