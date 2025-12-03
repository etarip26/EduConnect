import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:test_app/src/core/services/auth_service.dart';
import 'package:test_app/src/core/services/tuition_service.dart';
import 'package:test_app/src/ui/tuition/tuition_details_page.dart';
import 'package:test_app/src/ui/tuition/tuition_create_page.dart';

class TuitionTab extends StatefulWidget {
  const TuitionTab({super.key});

  @override
  State<TuitionTab> createState() => _TuitionTabState();
}

class _TuitionTabState extends State<TuitionTab> {
  final tuitionService = GetIt.instance<TuitionService>();
  final auth = GetIt.instance<AuthService>();

  bool loading = true;
  List posts = [];

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  // -----------------------------
  // LOAD ALL TUITION POSTS
  // -----------------------------
  Future<void> loadPosts() async {
    setState(() => loading = true);

    try {
      posts = await tuitionService.list();
    } catch (e) {
      debugPrint("LOAD TUITION ERROR: $e");
    }

    setState(() => loading = false);
  }

  // -----------------------------
  // MAIN UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final isStudent = auth.role == "student";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tuition Posts"),
        elevation: 0,
        centerTitle: true,
      ),

      floatingActionButton: isStudent
          ? FloatingActionButton.extended(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TuitionCreatePage()),
                ).then((_) => loadPosts());
              },
              label: const Text(
                "Create Tuition",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: const Icon(Icons.add),
            )
          : null,

      body: loading
          ? _shimmer()
          : posts.isEmpty
          ? _emptyState()
          : RefreshIndicator(
              onRefresh: loadPosts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (_, i) => _tuitionCard(posts[i]),
              ),
            ),
    );
  }

  // -----------------------------
  // PREMIUM TUITION CARD
  // -----------------------------
  Widget _tuitionCard(Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TuitionDetailsPage(post: post)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.65 * 255).round()),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 20,
                    spreadRadius: -10,
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    post["title"] ?? "Tuition Post",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _row(Icons.book, post["subject"]),
                  const SizedBox(height: 4),
                  _row(Icons.monetization_on, post["salary"]),
                  const SizedBox(height: 4),
                  _row(Icons.location_on, post["location"]),

                  const SizedBox(height: 14),

                  _viewButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, dynamic text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text?.toString() ?? "-",
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _viewButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF6A4DFE)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "View Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // -----------------------------
  // EMPTY STATE
  // -----------------------------
  Widget _emptyState() {
    return Center(
      child: Text(
        "No Tuition posts yet.",
        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
      ),
    );
  }

  // -----------------------------
  // SHIMMER / PLACEHOLDER
  // -----------------------------
  Widget _shimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
