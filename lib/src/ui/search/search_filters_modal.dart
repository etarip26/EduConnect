import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SearchFiltersModal extends StatefulWidget {
  final Map<String, dynamic> initial;
  final bool isStudentSearchingTeachers;

  const SearchFiltersModal({
    super.key,
    required this.initial,
    required this.isStudentSearchingTeachers,
  });

  @override
  State<SearchFiltersModal> createState() => _SearchFiltersModalState();
}

class _SearchFiltersModalState extends State<SearchFiltersModal> {
  late TextEditingController subjectC;
  late TextEditingController classLevelC;
  late TextEditingController cityC;
  late TextEditingController salaryMinC;
  late TextEditingController salaryMaxC;

  // Location-based search fields
  bool _useLocationFilter = false;
  double _radiusKm = 10;
  double? _lat;
  double? _lng;
  bool _gettingLocation = false;

  @override
  void initState() {
    super.initState();

    subjectC = TextEditingController(text: widget.initial["subject"]);
    classLevelC = TextEditingController(text: widget.initial["classLevel"]);
    cityC = TextEditingController(text: widget.initial["city"]);
    salaryMinC = TextEditingController(
      text: widget.initial["salaryMin"]?.toString() ?? "",
    );
    salaryMaxC = TextEditingController(
      text: widget.initial["salaryMax"]?.toString() ?? "",
    );

    // Restore location filter state if previously set
    _useLocationFilter = widget.initial["useLocationFilter"] ?? false;
    _radiusKm = widget.initial["radiusKm"] ?? 10;
    _lat = widget.initial["lat"];
    _lng = widget.initial["lng"];
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _gettingLocation = true);
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        final r = await Geolocator.requestPermission();
        if (r == LocationPermission.denied ||
            r == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          setState(() => _gettingLocation = false);
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _useLocationFilter = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    } finally {
      setState(() => _gettingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.isStudentSearchingTeachers;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.96 * 255).round()),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Text(
                "Search Filters",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Location-based radius filter
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.indigo, width: 2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Search by Location",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: _useLocationFilter,
                          activeThumbColor: Colors.indigo,
                          onChanged: (v) =>
                              setState(() => _useLocationFilter = v),
                        ),
                      ],
                    ),
                    if (_useLocationFilter) ...[
                      const SizedBox(height: 12),
                      if (_lat != null && _lng != null)
                        Text(
                          "Location: ${_lat!.toStringAsFixed(2)}, ${_lng!.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _gettingLocation
                            ? null
                            : _useCurrentLocation,
                        icon: const Icon(Icons.location_on, size: 18),
                        label: _gettingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Use Current Location"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Radius: ${_radiusKm.toStringAsFixed(1)} km",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Slider(
                            min: 1,
                            max: 50,
                            divisions: 49,
                            value: _radiusKm,
                            label: '${_radiusKm.toStringAsFixed(1)} km',
                            onChanged: (v) => setState(() => _radiusKm = v),
                            activeColor: Colors.indigo,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (isStudent) _input("Subject", subjectC),

              _input("Class Level", classLevelC),
              _input("City", cityC),

              if (isStudent) ...[
                _input("Min Salary", salaryMinC),
                _input("Max Salary", salaryMaxC),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  final filters = {
                    "subject": subjectC.text.trim(),
                    "classLevel": classLevelC.text.trim(),
                    "city": cityC.text.trim(),
                    "salaryMin": int.tryParse(salaryMinC.text),
                    "salaryMax": int.tryParse(salaryMaxC.text),
                    // Location-based filters
                    "useLocationFilter": _useLocationFilter,
                    "lat": _useLocationFilter ? _lat : null,
                    "lng": _useLocationFilter ? _lng : null,
                    "radiusKm": _useLocationFilter ? _radiusKm : null,
                  };
                  Navigator.pop(context, filters);
                },
                child: const Text(
                  "Apply Filters",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
