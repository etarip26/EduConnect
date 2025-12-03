import 'location_model.dart';

class StudentProfile {
  final String id;
  final String classLevel;
  final bool isVerified;
  final bool parentControlEnabled;
  final LocationPoint location;

  StudentProfile({
    required this.id,
    required this.classLevel,
    required this.isVerified,
    required this.parentControlEnabled,
    required this.location,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json["_id"] ?? "",
      classLevel: json["classLevel"] ?? "",
      isVerified: json["isVerified"] ?? false,
      parentControlEnabled: json["parentControlEnabled"] ?? false,
      location: LocationPoint.fromJson(json["location"]),
    );
  }
}
