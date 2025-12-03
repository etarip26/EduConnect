import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:test_app/src/core/services/auth_service.dart';
import 'package:test_app/src/core/services/tuition_service.dart';
import 'package:test_app/src/ui/tuition/tuition_details_page.dart';
import 'package:test_app/src/ui/tuition/tuition_create_page.dart';

class TuitionListPage extends StatefulWidget {
  final bool isTeacherView;

  const TuitionListPage({super.key, this.isTeacherView = false});

  @override
  State<TuitionListPage> createState() => _TuitionListPageState();
}

class _TuitionListPageState extends State<TuitionListPage> {
  final tuitionService = GetIt.instance<TuitionService>();
  final auth = GetIt.instance<AuthService>();

  bool loading = true;
  List posts = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);

    try {
      posts = await tuitionService.list();
    } catch (e) {
      print("LOAD TUITION ERROR: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final role = auth.role;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tuition Posts"),
        actions: [
          if (role == "student")
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                size: 30,
                color: Colors.indigo,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TuitionCreatePage()),
                ).then((_) => load());
              },
            ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
          ? const Center(
              child: Text(
                "No tuition posts found.",
                style: TextStyle(fontSize: 18),
              ),
            )
          : RefreshIndicator(
              onRefresh: load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (_, i) => _card(posts[i]),
              ),
            ),
    );
  }

  Widget _card(dynamic p) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TuitionDetailsPage(post: p)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF8F9FF), Color(0xFFEFF1FF)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 4),
              color: Colors.black12,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p['title'] ?? "Tuition Post",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.school, size: 18),
                const SizedBox(width: 6),
                Text("Class: ${p['classLevel'] ?? ''}"),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.menu_book, size: 18),
                const SizedBox(width: 6),
                Text("Subjects: ${(p['subjects'] ?? []).join(", ")}"),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.payments, size: 18),
                const SizedBox(width: 6),
                Text("Salary: ${p['salary'] ?? ''}"),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.red),
                const SizedBox(width: 6),
                Text("${p['city'] ?? ''}, ${p['area'] ?? ''}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
