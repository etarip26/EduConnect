import 'package:test_app/src/core/network/api_client.dart';

class SearchService {
  final ApiClient api;

  SearchService(this.api);

  // ---------------------------------------------------------
  // SEARCH TEACHERS
  // ---------------------------------------------------------
  Future<List<dynamic>> searchTeachers({
    String? subject,
    String? classLevel,
    String? city,
    int? minSalary,
    int? maxSalary,
  }) async {
    final query = <String, String>{};

    if (subject != null && subject.trim().isNotEmpty) {
      query["subject"] = subject.trim();
    }
    if (classLevel != null && classLevel.trim().isNotEmpty) {
      query["classLevel"] = classLevel.trim();
    }
    if (city != null && city.trim().isNotEmpty) {
      query["city"] = city.trim();
    }
    if (minSalary != null) {
      query["minSalary"] = minSalary.toString();
    }
    if (maxSalary != null) {
      query["maxSalary"] = maxSalary.toString();
    }

    final res = await api.get("/search/teachers", query: query);
    return res["teachers"] ?? [];
  }

  // ---------------------------------------------------------
  // SEARCH STUDENTS
  // ---------------------------------------------------------
  Future<List<dynamic>> searchStudents({
    String? subject,
    String? classLevel,
    String? city,
  }) async {
    final query = <String, String>{};

    if (subject != null && subject.trim().isNotEmpty) {
      query["subject"] = subject.trim();
    }
    if (classLevel != null && classLevel.trim().isNotEmpty) {
      query["classLevel"] = classLevel.trim();
    }
    if (city != null && city.trim().isNotEmpty) {
      query["city"] = city.trim();
    }

    final res = await api.get("/search/students", query: query);
    return res["students"] ?? [];
  }
}
