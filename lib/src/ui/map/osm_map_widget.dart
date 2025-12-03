import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:test_app/src/core/models/geo_location.dart';

/// A simple OpenStreetMap widget using `flutter_map`.
///
/// Usage:
/// ```dart
/// OSMMapWidget(
///   centerLat: 24.86,
///   centerLng: 67.01,
///   markers: [
///     {'lat': 24.86, 'lng': 67.01, 'label': 'You'},
///   ],
/// )
/// ```
class OSMMapWidget extends StatefulWidget {
  final double? centerLat;
  final double? centerLng;
  final List<dynamic>?
  markers; // each marker: Map or GeoLocation or object with toJson
  final double zoom;

  const OSMMapWidget({
    Key? key,
    this.centerLat,
    this.centerLng,
    this.markers,
    this.zoom = 13,
  }) : super(key: key);

  @override
  State<OSMMapWidget> createState() => _OSMMapWidgetState();
}

class _OSMMapWidgetState extends State<OSMMapWidget> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  LatLng _initialCenter() {
    final lat = widget.centerLat ?? 0.0;
    final lng = widget.centerLng ?? 0.0;
    return LatLng(lat, lng);
  }

  List<Marker> _buildMarkers() {
    final out = <Marker>[];
    if (widget.markers == null) return out;
    for (final m in widget.markers!) {
      double? lat;
      double? lng;
      String? label;
      if (m is GeoLocation) {
        lat = m.lat;
        lng = m.lng;
      } else if (m is Map<String, dynamic>) {
        if (m['coordinates'] is List && m['coordinates'].length >= 2) {
          lat = (m['coordinates'][1] ?? 0).toDouble();
          lng = (m['coordinates'][0] ?? 0).toDouble();
        } else {
          lat = (m['lat'] ?? m['latitude'])?.toDouble();
          lng = (m['lng'] ?? m['longitude'])?.toDouble();
        }
        label = m['label']?.toString();
      }
      if (lat == null || lng == null) continue;
      out.add(
        Marker(
          width: 40,
          height: 40,
          point: LatLng(lat, lng),
          builder: (ctx) => GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 32),
                if (label != null)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(label, style: TextStyle(fontSize: 10)),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final center = _initialCenter();
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(center: center, zoom: widget.zoom),
      children: [
        TileLayer(
          // Using OSM tile server with English language parameter
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.test_app',
          // Ensure English locale is used for map labels
          additionalOptions: {'language': 'en', 'locale': 'en_US'},
        ),
        MarkerLayer(markers: _buildMarkers()),
      ],
    );
  }
}
