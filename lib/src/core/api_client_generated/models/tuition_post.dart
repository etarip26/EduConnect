class TuitionPost {
  final String? id;
  final String? title;
  final Map<String, dynamic>?
  location; // contains { type, coordinates: [lng, lat], city, area }
  final double? distanceKm;

  TuitionPost({this.id, this.title, this.location, this.distanceKm});

  factory TuitionPost.fromJson(Map<String, dynamic> json) {
    double? distanceKm;
    // common places: distance_km (from our server), dist.calculated (meters)
    if (json['distance_km'] != null) {
      distanceKm = (json['distance_km'] is num)
          ? (json['distance_km'] as num).toDouble()
          : double.tryParse(json['distance_km'].toString());
    } else if (json['dist'] is Map && json['dist']['calculated'] != null) {
      final meters = (json['dist']['calculated'] is num)
          ? (json['dist']['calculated'] as num).toDouble()
          : double.tryParse(json['dist']['calculated'].toString());
      if (meters != null) distanceKm = meters / 1000.0;
    } else if (json['dist'] is num) {
      distanceKm = (json['dist'] as num).toDouble() / 1000.0;
    }

    final loc = json['location'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['location'])
        : null;

    return TuitionPost(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      title: json['title']?.toString(),
      location: loc,
      distanceKm: distanceKm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'location': location,
      'distance_km': distanceKm,
    };
  }
}
