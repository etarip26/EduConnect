class LocationPoint {
  final double lat;
  final double lng;
  final String city;
  final String area;

  LocationPoint({
    required this.lat,
    required this.lng,
    required this.city,
    required this.area,
  });

  factory LocationPoint.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LocationPoint(lat: 0, lng: 0, city: "", area: "");
    }

    final coords = json["coordinates"] ?? [0.0, 0.0];

    return LocationPoint(
      lat: (coords.length > 1 ? coords[1] : 0).toDouble(),
      lng: (coords.isNotEmpty ? coords[0] : 0).toDouble(),
      city: json["city"] ?? "",
      area: json["area"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": "Point",
      "coordinates": [lng, lat],
      "city": city,
      "area": area,
    };
  }
}
