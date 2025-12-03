import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/search_service.dart';
import '../../../core/services/tuition_service.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final searchService = GetIt.instance<SearchService>();
  final tuitionService = GetIt.instance<TuitionService>();

  List results = [];
  bool loading = false;

  // Filter controllers
  late TextEditingController subjectC;
  late TextEditingController classLevelC;
  late TextEditingController cityC;
  late TextEditingController salaryMinC;
  late TextEditingController salaryMaxC;

  // Location-based search
  bool _useLocationFilter = false;
  double _radiusKm = 10;
  double? _lat;
  double? _lng;
  bool _gettingLocation = false;

  @override
  void initState() {
    super.initState();
    subjectC = TextEditingController();
    classLevelC = TextEditingController();
    cityC = TextEditingController();
    salaryMinC = TextEditingController();
    salaryMaxC = TextEditingController();
  }

  @override
  void dispose() {
    subjectC.dispose();
    classLevelC.dispose();
    cityC.dispose();
    salaryMinC.dispose();
    salaryMaxC.dispose();
    super.dispose();
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
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    } finally {
      setState(() => _gettingLocation = false);
    }
  }

  Future<void> doSearch() async {
    setState(() => loading = true);
    try {
      if (_useLocationFilter && _lat != null && _lng != null) {
        // Use location-based search with filters
        results = await tuitionService.listNearbyServerWithFilters(
          lat: _lat!,
          lng: _lng!,
          radiusKm: _radiusKm,
          classLevel: classLevelC.text.isNotEmpty ? classLevelC.text : null,
          subjects: subjectC.text.isNotEmpty ? [subjectC.text] : null,
          city: cityC.text.isNotEmpty ? cityC.text : null,
        );
      } else {
        // Use regular search
        results = await searchService.searchTeachers();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Tutors & Teachers"),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.withAlpha((0.05 * 255).round()),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withAlpha((0.1 * 255).round()),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filters",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Basic Filters Row
                  Row(
                    children: [
                      Expanded(child: _filterField("Subject", subjectC)),
                      const SizedBox(width: 12),
                      Expanded(child: _filterField("Class Level", classLevelC)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // City and Salary Filters Row
                  Row(
                    children: [
                      Expanded(child: _filterField("City", cityC)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _filterField(
                          "Min Salary",
                          salaryMinC,
                          inputType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _filterField(
                    "Max Salary",
                    salaryMaxC,
                    inputType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Location Filter
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.indigo, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Search by Location",
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                          const SizedBox(height: 8),
                          if (_lat != null && _lng != null)
                            Text(
                              "📍 Lat: ${_lat!.toStringAsFixed(3)}, Lng: ${_lng!.toStringAsFixed(3)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _gettingLocation
                                ? null
                                : _useCurrentLocation,
                            icon: const Icon(Icons.location_on, size: 18),
                            label: _gettingLocation
                                ? const Text("Getting location...")
                                : const Text("Use Current Location"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Radius: ${_radiusKm.toStringAsFixed(1)} km",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  min: 1,
                                  max: 50,
                                  divisions: 49,
                                  value: _radiusKm,
                                  label: '${_radiusKm.toStringAsFixed(1)} km',
                                  onChanged: (v) =>
                                      setState(() => _radiusKm = v),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: loading ? null : doSearch,
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              "Search",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Results Section
            if (results.isEmpty && !loading)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No results yet",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Try adjusting your filters",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Results (${results.length})",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final r = results[i];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r["name"] ?? "Unknown",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (r["subjects"] != null)
                                Text(
                                  "📚 ${r["subjects"].join(', ')}",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              if (r["location"]?["city"] != null)
                                Text(
                                  "📍 ${r["location"]["city"]}",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _filterField(
    String label,
    TextEditingController controller, {
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}
