class GeoLocation {
  final double? lat;
  final double? lng;
  final String? city;
  final String? area;

  GeoLocation({this.lat, this.lng, this.city, this.area});

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    double? lat;
    double? lng;

    // -------------------------
    // BACKEND FORMAT PARSING
    // -------------------------
    if (json["coordinates"] != null && json["coordinates"] is List) {
      // backend sends: coordinates: [lng, lat]
      final coords = json["coordinates"];
      if (coords.length >= 2) {
        lng = (coords[0] != null) ? coords[0].toDouble() : null;
        lat = (coords[1] != null) ? coords[1].toDouble() : null;
      }
    }

    // -------------------------
    // UI FORMAT PARSING (fallback)
    // -------------------------
    lat ??= json["lat"] != null ? json["lat"].toDouble() : null;
    lng ??= json["lng"] != null ? json["lng"].toDouble() : null;

    return GeoLocation(
      lat: lat,
      lng: lng,
      city: json["city"],
      area: json["area"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"lat": lat, "lng": lng, "city": city ?? "", "area": area ?? ""};
  }
}
