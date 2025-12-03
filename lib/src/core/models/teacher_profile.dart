import 'location_model.dart';

class TeacherProfile {
  final String id;
  final List<String> subjects;
  final List<String> classLevels;
  final int expectedSalaryMin;
  final int expectedSalaryMax;
  final String university;
  final String department;
  final String jobTitle;
  final String about;
  final bool isVerified;
  final double ratingAverage;
  final int ratingCount;
  final LocationPoint location;

  TeacherProfile({
    required this.id,
    required this.subjects,
    required this.classLevels,
    required this.expectedSalaryMin,
    required this.expectedSalaryMax,
    required this.university,
    required this.department,
    required this.jobTitle,
    required this.about,
    required this.isVerified,
    required this.ratingAverage,
    required this.ratingCount,
    required this.location,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    return TeacherProfile(
      id: json["_id"] ?? "",
      subjects: List<String>.from(json["subjects"] ?? []),
      classLevels: List<String>.from(json["classLevels"] ?? []),
      expectedSalaryMin: (json["expectedSalaryMin"] ?? 0).toInt(),
      expectedSalaryMax: (json["expectedSalaryMax"] ?? 0).toInt(),
      university: json["university"] ?? "",
      department: json["department"] ?? "",
      jobTitle: json["jobTitle"] ?? "",
      about: json["about"] ?? "",
      isVerified: json["isVerified"] ?? false,
      ratingAverage: (json["ratingAverage"] ?? 0).toDouble(),
      ratingCount: (json["ratingCount"] ?? 0).toInt(),
      location: LocationPoint.fromJson(json["location"]),
    );
  }
}
