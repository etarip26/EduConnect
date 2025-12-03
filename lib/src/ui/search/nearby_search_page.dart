import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:test_app/src/core/services/tuition_service.dart';
import 'package:test_app/src/core/services/service_locator.dart';
import 'package:test_app/src/core/utils/location_utils.dart';
import 'package:test_app/src/ui/map/osm_map_widget.dart';

class NearbySearchPage extends StatefulWidget {
  const NearbySearchPage({Key? key}) : super(key: key);

  @override
  State<NearbySearchPage> createState() => _NearbySearchPageState();
}

class _NearbySearchPageState extends State<NearbySearchPage> {
  final TuitionService _tuitionService = sl<TuitionService>();

  double _radiusKm = 10;
  double? _lat;
  double? _lng;
  bool _loading = false;
  List<dynamic> _posts = [];
  List<Map<String, dynamic>> _postsWithDistance = [];
  bool _useServerDistance = false;

  Future<void> _useCurrentLocation() async {
    setState(() => _loading = true);
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        final r = await Geolocator.requestPermission();
        if (r == LocationPermission.denied ||
            r == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          setState(() => _loading = false);
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _findNearby() async {
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a center location first')),
      );
      return;
    }
    setState(() {
      _loading = true;
      _posts = [];
    });
    try {
      final posts = await _tuitionService.listNearbyServerWithFilters(
        lat: _lat!,
        lng: _lng!,
        radiusKm: _radiusKm,
      );
      // compute distances (km) for display
      final withDist = <Map<String, dynamic>>[];
      for (final p in posts) {
        if (p is Map<String, dynamic>) {
          double? plat;
          double? plng;
          if (p['location'] != null &&
              p['location']['coordinates'] is List &&
              p['location']['coordinates'].length >= 2) {
            plat = (p['location']['coordinates'][1] ?? 0).toDouble();
            plng = (p['location']['coordinates'][0] ?? 0).toDouble();
          } else if (p['lat'] != null && p['lng'] != null) {
            plat = (p['lat']).toDouble();
            plng = (p['lng']).toDouble();
          }

          double? distKm;
          // If user requested server distances, attempt to read server-provided distance
          if (_useServerDistance) {
            // Common server distance placements: { dist: { calculated: <meters> } } or { distance: <meters> }
            try {
              final maybeDistField =
                  p['dist'] is Map && p['dist']['calculated'] != null
                  ? p['dist']['calculated']
                  : p['distance'] ?? p['dist'];
              if (maybeDistField != null) {
                final meters = (maybeDistField is num)
                    ? maybeDistField.toDouble()
                    : double.tryParse(maybeDistField.toString());
                if (meters != null) distKm = meters / 1000.0;
              }
            } catch (_) {
              // ignore and fallback
            }
          }

          // Fallback to client-side Haversine if server distance not available
          if (distKm == null &&
              plat != null &&
              plng != null &&
              _lat != null &&
              _lng != null) {
            distKm = haversineDistanceKm(_lat!, _lng!, plat, plng);
          }

          final copy = Map<String, dynamic>.from(p);
          copy['__distanceKm'] = distKm;
          withDist.add(copy);
        }
      }

      // sort by distance (nulls last)
      withDist.sort((a, b) {
        final da = a['__distanceKm'] as double?;
        final db = b['__distanceKm'] as double?;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });

      setState(() {
        _posts = posts;
        _postsWithDistance = withDist;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  List<dynamic> _markerList() {
    return _postsWithDistance.map((p) {
      final coords = p['location']?['coordinates'];
      final labelBase = p['title'] ?? p['studentId']?.toString() ?? 'Tutor';
      final dist = p['__distanceKm'];
      final label = dist != null
          ? '$labelBase (${dist.toStringAsFixed(1)} km)'
          : labelBase;
      return {'coordinates': coords, 'label': label};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final centerLat = _lat ?? 24.8607;
    final centerLng = _lng ?? 67.0011;
    final markers = _markerList();

    return Scaffold(
      appBar: AppBar(title: const Text('Find Nearby Tutors')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Radius: ${_radiusKm.toStringAsFixed(1)} km'),
                      Row(
                        children: [
                          const Text('Use server distances'),
                          Switch(
                            value: _useServerDistance,
                            onChanged: (v) =>
                                setState(() => _useServerDistance = v),
                          ),
                        ],
                      ),
                      Slider(
                        min: 1,
                        max: 50,
                        divisions: 49,
                        value: _radiusKm,
                        label: '${_radiusKm.toStringAsFixed(1)} km',
                        onChanged: (v) => setState(() => _radiusKm = v),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _loading ? null : _useCurrentLocation,
                      child: const Text('Use Current Location'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loading ? null : _findNearby,
                      child: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Find Nearby'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map
          Expanded(
            child: OSMMapWidget(
              centerLat: centerLat,
              centerLng: centerLng,
              markers: markers.cast<dynamic>(),
              zoom: 12,
            ),
          ),

          // Results list
          Container(
            height: 180,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                ? const Center(child: Text('No posts found'))
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (ctx, i) {
                      final p = _postsWithDistance[i];
                      final dist = p['__distanceKm'] as double?;
                      return ListTile(
                        title: Text(p['title'] ?? 'Tutor Post'),
                        subtitle: Text(p['location']?['city'] ?? ''),
                        trailing: dist != null
                            ? Text('${dist.toStringAsFixed(1)} km')
                            : null,
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(),
                    itemCount: _postsWithDistance.length,
                  ),
          ),
        ],
      ),
    );
  }
}
