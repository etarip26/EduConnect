import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/tuition_service.dart';

class MyApplicationsPage extends StatefulWidget {
  final String postId;

  const MyApplicationsPage({super.key, required this.postId});

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  final tuitionService = GetIt.instance<TuitionService>();

  bool loading = true;
  List apps = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      apps = await tuitionService.myApplications();
    } catch (_) {
      apps = [];
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Applications")),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: apps.length,
        itemBuilder: (_, i) {
          final p = apps[i]["postId"] ?? {};
          return ListTile(title: Text(p["title"] ?? "Post"));
        },
      ),
    );
  }
}
