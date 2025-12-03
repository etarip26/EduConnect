import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/tuition_service.dart';
import 'package:test_app/src/core/utils/snackbar_utils.dart';

class TuitionCreatePage extends StatefulWidget {
  const TuitionCreatePage({super.key});

  @override
  State<TuitionCreatePage> createState() => _TuitionCreatePageState();
}

class _TuitionCreatePageState extends State<TuitionCreatePage> {
  final TuitionService tuitionService = GetIt.instance<TuitionService>();

  final titleC = TextEditingController();
  final detailsC = TextEditingController();
  final classLevelC = TextEditingController();
  final subjectsC = TextEditingController(); // comma separated

  final salaryMinC = TextEditingController();
  final salaryMaxC = TextEditingController();

  final cityC = TextEditingController();
  final areaC = TextEditingController();
  final latC = TextEditingController();
  final lngC = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Create Tuition"),
      ),
      body: Stack(children: [_background(), _form()]),
    );
  }

  Widget _background() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF6A4DFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _form() {
    return Positioned.fill(
      top: 100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.68 * 255).round()),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  _input("Title", titleC),
                  _input("Details", detailsC, lines: 3),
                  _input("Class Level (ex: Class 8)", classLevelC),
                  _input("Subjects (comma separated)", subjectsC),
                  _input("Min Salary", salaryMinC, type: TextInputType.number),
                  _input("Max Salary", salaryMaxC, type: TextInputType.number),

                  const SizedBox(height: 20),
                  const Text(
                    "Location",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),

                  _input("City", cityC),
                  _input("Area", areaC),
                  _input("Latitude", latC, type: TextInputType.number),
                  _input("Longitude", lngC, type: TextInputType.number),

                  const SizedBox(height: 28),
                  loading ? const CircularProgressIndicator() : _createButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController c, {
    int lines = 1,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        keyboardType: type,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _createButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _create,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text("Create Tuition", style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Future<void> _create() async {
    final subjects = subjectsC.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final body = {
      "title": titleC.text.trim(),
      "details": detailsC.text.trim(),
      "classLevel": classLevelC.text.trim(),
      "subjects": subjects,
      "salaryMin": int.tryParse(salaryMinC.text) ?? 0,
      "salaryMax": int.tryParse(salaryMaxC.text) ?? 0,
      "location": {
        "city": cityC.text.trim(),
        "area": areaC.text.trim(),
        "lat": double.tryParse(latC.text) ?? 0,
        "lng": double.tryParse(lngC.text) ?? 0,
      },
    };

    setState(() => loading = true);

    try {
      await tuitionService.create(body);
      showSnackBar(context, "Tuition posted successfully!");
      Navigator.pop(context);
    } catch (e) {
      showSnackBar(context, "Failed: $e", isError: true);
    }

    setState(() => loading = false);
  }
}
