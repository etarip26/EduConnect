import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/admin_service.dart';
import 'package:test_app/src/core/utils/snackbar_utils.dart';

class AdminTab extends StatefulWidget {
  const AdminTab({super.key});

  @override
  State<AdminTab> createState() => _AdminTabState();
}

class _AdminTabState extends State<AdminTab> {
  final admin = GetIt.instance<AdminService>();

  bool loading = true;

  Map<String, dynamic>? stats;
  List<dynamic> users = [];
  List<dynamic> tuitions = [];
  List<dynamic> teachers = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);

    try {
      stats = await admin.getStats();
      users = await admin.getUsers();
      teachers = await admin.getTeachersPending();
      tuitions = await admin.getTuitionsPending();
    } catch (e) {
      showSnackBar(context, "Admin load failed: $e", isError: true);
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Admin Dashboard",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            //===============================
            // ADMIN STATS
            //===============================
            _sectionTitle("📊 Overview Stats"),
            _statsGrid(),

            const SizedBox(height: 30),

            //===============================
            // USERS MANAGEMENT
            //===============================
            _sectionTitle("👥 Users"),
            _userList(),

            const SizedBox(height: 30),

            //===============================
            // TEACHER APPROVALS
            //===============================
            _sectionTitle("🎓 Teacher Approvals"),
            _teacherApprovalList(),

            const SizedBox(height: 30),

            //===============================
            // TUITION APPROVALS
            //===============================
            _sectionTitle("📘 Tuition Approvals"),
            _tuitionApprovalList(),
          ],
        ),
      ),
    );
  }

  //===========================================================
  // SECTION TITLE
  //===========================================================
  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.indigo,
      ),
    ),
  );

  //===========================================================
  // STATS GRID
  //===========================================================
  Widget _statsGrid() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      children: [
        _statCard("Total Users", stats?["totalUsers"]),
        _statCard("Students", stats?["students"]),
        _statCard("Teachers", stats?["teachers"]),
        _statCard("Active Tuitions", stats?["activeTuitions"]),
        _statCard("Pending Tuitions", stats?["pendingTuitions"]),
        _statCard("Demo Requests", stats?["demoRequests"]),
      ],
    );
  }

  Widget _statCard(String title, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$value",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  //===========================================================
  // USERS LIST
  //===========================================================
  Widget _userList() {
    return Column(
      children: users.map((u) {
        final suspended = u["isSuspended"] == true;

        return Card(
          child: ListTile(
            title: Text(u["name"]),
            subtitle: Text("${u["email"]} • ${u["role"]}"),
            trailing: Switch(
              value: suspended,
              activeThumbColor: Colors.red,
              onChanged: (_) async {
                await admin.toggleSuspend(u["id"]);
                loadData();
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  //===========================================================
  // TEACHER APPROVAL LIST
  //===========================================================
  Widget _teacherApprovalList() {
    if (teachers.isEmpty) {
      return const Text(
        "No pending teacher verifications",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children: teachers.map((t) {
        return Card(
          child: ListTile(
            title: Text(t["fullName"] ?? "Unknown"),
            subtitle: Text("Department: ${t["department"]}"),
            trailing: ElevatedButton(
              onPressed: () async {
                await admin.approveTeacher(t["userId"]);
                loadData();
              },
              child: const Text("Approve"),
            ),
          ),
        );
      }).toList(),
    );
  }

  //===========================================================
  // TUITION APPROVAL LIST
  //===========================================================
  Widget _tuitionApprovalList() {
    if (tuitions.isEmpty) {
      return const Text(
        "No pending tuition posts",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children: tuitions.map((post) {
        return Card(
          child: ListTile(
            title: Text(post["subject"]),
            subtitle: Text("${post["city"]}, ${post["classLevel"]}"),
            trailing: ElevatedButton(
              onPressed: () async {
                await admin.approveTuition(post["_id"]);
                loadData();
              },
              child: const Text("Approve"),
            ),
          ),
        );
      }).toList(),
    );
  }
}
