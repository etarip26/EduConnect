import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:test_app/src/core/services/auth_service.dart';
import 'package:test_app/src/core/services/tuition_service.dart';
import 'package:test_app/src/ui/tuition/tuition_details_page.dart';

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
    return loading
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
          );
  }

  Widget _card(dynamic p) {
    final isOwner = p['postedBy'] == auth.user?.id;

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
            // Header with Title and Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    p['title'] ?? "Tuition Post",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (_) => [
                    if (isOwner)
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                        onTap: () {
                          _showEditTuitionDialog(context, p);
                        },
                      ),
                    if (isOwner)
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        onTap: () {
                          _showDeleteConfirmationDialog(context, p['_id']);
                        },
                      ),
                    if (!isOwner)
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.report, size: 20, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              'Report',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ],
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Report sent')),
                          );
                        },
                      ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.share, size: 20),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share functionality')),
                        );
                      },
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Card Details
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
                Expanded(
                  child: Text(
                    "Subjects: ${(p['subjects'] ?? []).join(", ")}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
                Expanded(
                  child: Text(
                    "${p['city'] ?? ''}, ${p['area'] ?? ''}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTuitionDialog(
    BuildContext context,
    Map<String, dynamic> tuition,
  ) {
    final titleController = TextEditingController(text: tuition['title'] ?? '');
    final descriptionController = TextEditingController(
      text: tuition['description'] ?? '',
    );
    final salaryController = TextEditingController(
      text: tuition['salary']?.toString() ?? '',
    );
    final classLevelController = TextEditingController(
      text: tuition['classLevel'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tuition'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: classLevelController,
                decoration: const InputDecoration(labelText: 'Class Level'),
              ),
              TextField(
                controller: salaryController,
                decoration: const InputDecoration(labelText: 'Salary'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tuition updated successfully')),
              );
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 300), () {
                setState(() {});
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String tuitionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tuition'),
        content: const Text(
          'Are you sure you want to delete this tuition? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tuition deleted successfully')),
              );
              Future.delayed(const Duration(milliseconds: 300), () {
                setState(() {});
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
