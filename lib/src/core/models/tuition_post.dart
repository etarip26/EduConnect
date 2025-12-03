import 'location_model.dart';

class TuitionPost {
  final String id;
  final String studentId;
  final String title;
  final String details;
  final String classLevel;
  final List<String> subjects;
  final int salaryMin;
  final int salaryMax;
  final bool isClosed;
  final LocationPoint location;

  TuitionPost({
    required this.id,
    required this.studentId,
    required this.title,
    required this.details,
    required this.classLevel,
    required this.subjects,
    required this.salaryMin,
    required this.salaryMax,
    required this.isClosed,
    required this.location,
  });

  factory TuitionPost.fromJson(Map<String, dynamic> json) {
    return TuitionPost(
      id: json["_id"] ?? "",
      studentId: json["studentId"] ?? "",
      title: json["title"] ?? "",
      details: json["details"] ?? "",
      classLevel: json["classLevel"] ?? "",
      subjects: List<String>.from(json["subjects"] ?? []),
      salaryMin: (json["salaryMin"] ?? 0).toInt(),
      salaryMax: (json["salaryMax"] ?? 0).toInt(),
      isClosed: json["isClosed"] ?? false,
      location: LocationPoint.fromJson(json["location"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "studentId": studentId,
      "title": title,
      "details": details,
      "classLevel": classLevel,
      "subjects": subjects,
      "salaryMin": salaryMin,
      "salaryMax": salaryMax,
      "isClosed": isClosed,
      "location": location.toJson(),
    };
  }
}
