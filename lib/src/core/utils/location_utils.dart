import 'dart:math' as math;

import 'package:test_app/src/core/models/geo_location.dart';

/// Returns distance in kilometers between two lat/lng points using Haversine.
double haversineDistanceKm(double lat1, double lng1, double lat2, double lng2) {
  const R = 6371.0; // Earth radius in km
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lng2 - lng1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.pow(math.sin(dLon / 2), 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return R * c;
}

double _toRadians(double deg) => deg * (math.pi / 180);

/// Given a list of items that contain a `location` map or coordinates, filter by radiusKm.
///
/// Expected item shapes (common cases):
/// - item["location"] -> Map with `coordinates` (List [lng, lat]) or `lat`/`lng` double fields
/// - item itself may have `lat`/`lng` fields
List<T> filterByRadius<T>(
  List<T> items,
  double centerLat,
  double centerLng,
  double radiusKm, {
  double Function(T item)? extractLat,
  double Function(T item)? extractLng,
}) {
  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  double _extractLat(T item) {
    if (extractLat != null) return extractLat(item);
    final map = _toMap(item);
    if (map == null) return double.nan;
    final coords = map['coordinates'];
    if (coords is List && coords.length >= 2) {
      return _toDouble(coords[1]);
    }
    if (map['lat'] != null) return _toDouble(map['lat']);
    return double.nan;
  }

  double _extractLng(T item) {
    if (extractLng != null) return extractLng(item);
    final map = _toMap(item);
    if (map == null) return double.nan;
    final coords = map['coordinates'];
    if (coords is List && coords.length >= 2) {
      return _toDouble(coords[0]);
    }
    if (map['lng'] != null) return _toDouble(map['lng']);
    return double.nan;
  }

  final out = <T>[];
  for (final item in items) {
    final lat = _extractLat(item);
    final lng = _extractLng(item);
    if (lat.isNaN || lng.isNaN) continue;
    final d = haversineDistanceKm(centerLat, centerLng, lat, lng);
    if (d <= radiusKm) out.add(item);
  }
  return out;
}

/// Helper to convert common item shapes to Map<String, dynamic> when possible.
Map<String, dynamic>? _toMap(dynamic item) {
  if (item == null) return null;
  if (item is Map<String, dynamic>) return item;
  try {
    if (item is GeoLocation) {
      return item.toJson();
    }
    // Try to call toJson dynamically; guard with try/catch to avoid analyzer issues
    final maybe = (item as dynamic).toJson();
    if (maybe is Map<String, dynamic>) return maybe;
  } catch (_) {}
  return null;
}
