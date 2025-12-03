import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:test_app/src/core/services/tuition_service.dart';
import 'package:test_app/src/core/services/chat_service.dart';
import 'package:test_app/src/core/services/auth_service.dart';
import 'package:test_app/src/core/utils/snackbar_utils.dart';

import 'package:test_app/src/ui/chat/chat_detail_page.dart';
import 'package:test_app/src/core/widgets/app_avatar.dart';

class TuitionDetailsPage extends StatefulWidget {
  final Map<String, dynamic> post;
  const TuitionDetailsPage({super.key, required this.post});

  @override
  State<TuitionDetailsPage> createState() => _TuitionDetailsPageState();
}

class _TuitionDetailsPageState extends State<TuitionDetailsPage> {
  final tuitionService = GetIt.instance<TuitionService>();
  final chatService = GetIt.instance<ChatService>();
  final auth = GetIt.instance<AuthService>();

  bool loading = false;
  List<dynamic> applications = [];

  @override
  void initState() {
    super.initState();
    loadApplications();
  }

  Future<void> loadApplications() async {
    if (auth.role != "student") return;

    try {
      final data = await tuitionService.getApplications(widget.post["_id"]);
      applications = data["applications"] ?? [];
      setState(() {});
    } catch (e) {
      print("❌ Error loading applications: $e");
    }
  }

  // ------------------------------------------------------------
  // ACCEPT APPLICATION → create match → create chat → open chat
  // ------------------------------------------------------------
  Future<void> acceptApplication(String appId) async {
    setState(() => loading = true);

    try {
      final res = await tuitionService.acceptApplication(appId);

      final matchId = res["matchId"];
      if (matchId == null) {
        showSnackBar(context, "Match not created", isError: true);
        return;
      }

      final room = await chatService.createOrGetRoom(matchId);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatDetailPage(roomId: room["_id"])),
      );
    } catch (e) {
      showSnackBar(context, "Accept failed: $e", isError: true);
    }

    setState(() => loading = false);
  }

  // ------------------------------------------------------------
  // Teacher apply button
  // ------------------------------------------------------------
  Future<void> apply() async {
    try {
      await tuitionService.applyToPost(widget.post["_id"]);
      showSnackBar(context, "Applied successfully!");
    } catch (e) {
      showSnackBar(context, "Failed to apply", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    final subjectsText =
        (post["subjects"] as List?)?.join(", ") ?? "Not specified";

    return Scaffold(
      appBar: AppBar(title: const Text("Tuition Details")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // TITLE
                  // ------------------------------------------------
                  Text(
                    post["title"] ?? "Tuition Post",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  detailRow("Class Level", post["classLevel"]),
                  detailRow("Subjects", subjectsText),
                  detailRow(
                    "Salary Range",
                    "${post["salaryMin"]} – ${post["salaryMax"]} BDT",
                  ),
                  detailRow(
                    "Location",
                    "${post["location"]?["area"]}, ${post["location"]?["city"]}",
                  ),

                  const Divider(height: 40),

                  // ------------------------------------------------
                  // STUDENT VIEW → list applications
                  // ------------------------------------------------
                  if (auth.role == "student") ...[
                    const Text(
                      "Teacher Applications",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (applications.isEmpty) const Text("No applications yet"),

                    for (final app in applications) _applicationTile(app),
                  ],

                  // ------------------------------------------------
                  // TEACHER VIEW → Apply button
                  // ------------------------------------------------
                  if (auth.role == "teacher")
                    ElevatedButton(
                      onPressed: apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Apply for this Tuition"),
                    ),
                ],
              ),
            ),
    );
  }

  // ------------------------------------------------------------
  // UI COMPONENTS
  // ------------------------------------------------------------

  Widget detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? "-")),
        ],
      ),
    );
  }

  Widget _applicationTile(dynamic app) {
    final teacher = app["teacher"] ?? {}; // backend should populate this later

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: AppAvatar(name: teacher["name"], radius: 20),
        title: Text(teacher["name"] ?? "Teacher"),
        subtitle: Text(
          "Applied on: ${app["createdAt"]?.toString().split("T")[0]}",
        ),
        trailing: ElevatedButton(
          onPressed: () => acceptApplication(app["_id"]),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text("Accept"),
        ),
      ),
    );
  }
}
