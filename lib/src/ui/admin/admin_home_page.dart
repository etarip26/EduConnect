import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/admin_service.dart';
import 'package:test_app/src/core/services/auth_service.dart';
import 'package:test_app/src/core/utils/snackbar_utils.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final admin = GetIt.instance<AdminService>();
  final auth = GetIt.instance<AuthService>();

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

    // Load each API independently so one failure doesn't crash everything
    try {
      stats = await admin.getStats();
    } catch (e) {
      print("Error fetching stats: $e");
      stats = {};
    }

    try {
      users = await admin.getUsers();
    } catch (e) {
      print("Error fetching users: $e");
      users = [];
    }

    try {
      teachers = await admin.getTeachersPending();
    } catch (e) {
      print("Error fetching pending teachers: $e");
      teachers = [];
    }

    try {
      tuitions = await admin.getTuitionsPending();
    } catch (e) {
      print("Error fetching pending tuitions: $e");
      tuitions = [];
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    _welcomeSection(),
                    const SizedBox(height: 32),

                    // Platform Overview Card
                    _platformOverviewCard(),
                    const SizedBox(height: 28),

                    // Key Metrics (3 cards)
                    _keyMetricsRow(),
                    const SizedBox(height: 32),

                    // Recent Users Table
                    _recentUsersSection(),
                    const SizedBox(height: 32),

                    // Demo Requests Section
                    _demoRequestsSection(),
                    const SizedBox(height: 32),

                    // Pending Approvals
                    if (teachers.isNotEmpty || tuitions.isNotEmpty)
                      _pendingApprovalsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  //===========================================================
  // APP BAR
  //===========================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Admin Dashboard",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              auth.user?.email ?? "Admin",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ),
        PopupMenuButton<String>(
          itemBuilder: (_) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'reload',
              child: const Row(
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 12),
                  Text('Reload'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'logout',
              child: const Row(
                children: [
                  Icon(Icons.logout, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Logout', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'reload') {
              loadData();
              showSnackBar(context, 'Dashboard refreshed');
            } else if (value == 'logout') {
              // Logout logic here
            }
          },
          icon: const Icon(Icons.more_vert),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  //===========================================================
  // WELCOME SECTION
  //===========================================================
  Widget _welcomeSection() {
    final firstName = (auth.user?.name ?? 'Admin').split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back, $firstName!",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Here's what's happening on your platform today.",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  //===========================================================
  // PLATFORM OVERVIEW CARD
  //===========================================================
  Widget _platformOverviewCard() {
    final totalUsers = stats?["totalUsers"] ?? 0;
    final students = stats?["students"] ?? 0;
    final teachers = stats?["teachers"] ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withAlpha((0.3 * 255).round()),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dashboard_customize,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Platform Overview",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$totalUsers users • $students students • $teachers teachers",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //===========================================================
  // KEY METRICS ROW (3 cards)
  //===========================================================
  Widget _keyMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            icon: Icons.school_outlined,
            title: "Active Tuitions",
            value: "${stats?["activeTuitions"] ?? 0}",
            color: const Color(0xFF10B981),
            lightColor: const Color(0xFFD1FAE5),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _metricCard(
            icon: Icons.pending_actions_outlined,
            title: "Pending Approvals",
            value: "${(stats?["pendingTuitions"] ?? 0) + teachers.length}",
            color: const Color(0xFFF59E0B),
            lightColor: const Color(0xFFFEF3C7),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _metricCard(
            icon: Icons.video_call_outlined,
            title: "Demo Requests",
            value: "${stats?["demoRequests"] ?? 0}",
            color: const Color(0xFF3B82F6),
            lightColor: const Color(0xFFDBEAFE),
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color lightColor,
  }) {
    return GestureDetector(
      onTap: title == "Pending Approvals"
          ? () {
              showDialog(
                context: context,
                builder: (_) => _buildPendingApprovalsDialog(),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.04 * 255).round()),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //===========================================================
  // RECENT USERS SECTION
  //===========================================================
  Widget _recentUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Users",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              "View all",
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.04 * 255).round()),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        "User",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Role",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Status",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Rows
              ...users.take(6).map((u) {
                final suspended = u["isSuspended"] == true;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade50),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  (u["name"] ?? "U")[0].toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    u["name"] ?? "Unknown",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    u["email"] ?? "",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            u["role"] ?? "user",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: suspended
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            suspended ? "Suspended" : "Active",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: suspended
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  //===========================================================
  // DEMO REQUESTS SECTION
  //===========================================================
  Widget _demoRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Demo Requests",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.04 * 255).round()),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              "No demo requests yet.",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  //===========================================================
  // PENDING APPROVALS SECTION
  //===========================================================
  Widget _pendingApprovalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pending Approvals",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (teachers.isNotEmpty)
              Expanded(
                child: _approvalCard(
                  title: "Teacher Verifications",
                  count: teachers.length,
                  icon: Icons.person_4_outlined,
                  color: const Color(0xFF8B5CF6),
                  lightColor: const Color(0xFFEDE9FE),
                ),
              ),
            if (teachers.isNotEmpty && tuitions.isNotEmpty)
              const SizedBox(width: 16),
            if (tuitions.isNotEmpty)
              Expanded(
                child: _approvalCard(
                  title: "Tuition Posts",
                  count: tuitions.length,
                  icon: Icons.book_outlined,
                  color: const Color(0xFFF59E0B),
                  lightColor: const Color(0xFFFEF3C7),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _approvalCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color lightColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "$count pending",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Needs your attention",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalsDialog() {
    return AlertDialog(
      title: const Text("Pending Approvals"),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tuitions.isNotEmpty) ...[
                const Text(
                  "Tuition Posts",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tuitions.length,
                  itemBuilder: (_, index) {
                    final t = tuitions[index];
                    return ListTile(
                      title: Text(t["title"] ?? "Unknown"),
                      subtitle: Text(
                        "${t["location"]?["city"] ?? "Location"}, Class ${t["classLevel"] ?? "?"}",
                      ),
                    );
                  },
                ),
              ],
              if (teachers.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  "Teacher Verifications",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: teachers.length,
                  itemBuilder: (_, index) {
                    final t = teachers[index];
                    return ListTile(
                      title: Text(t["name"] ?? "Unknown"),
                      subtitle: Text(t["email"] ?? "No email"),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
