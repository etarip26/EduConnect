import 'package:flutter/material.dart';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:test_app/src/core/services/profile_image_service.dart';
import 'package:test_app/src/core/services/storage_service.dart';

import 'package:test_app/src/core/services/auth_service.dart';
import 'package:test_app/src/core/services/profile_service.dart';
import 'package:test_app/src/core/services/tuition_service.dart';
import 'package:test_app/src/core/utils/snackbar_utils.dart';
import 'package:test_app/src/ui/tuition/tuition_create_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final auth = GetIt.instance<AuthService>();
  final profileService = GetIt.instance<ProfileService>();
  final tuitionService = GetIt.instance<TuitionService>();

  bool loading = true;
  Map<String, dynamic>? user;
  Map<String, dynamic>? profile;
  List<dynamic> myTuitions = [];
  List<dynamic> myApplications = [];

  bool editMode = false;

  // BASIC
  final nameC = TextEditingController();
  final phoneC = TextEditingController();

  // Student fields
  final classLevelC = TextEditingController();
  final schoolC = TextEditingController();
  final guardianNameC = TextEditingController();
  final guardianPhoneC = TextEditingController();
  final guardianNidC = TextEditingController();
  final cityC = TextEditingController();
  final areaC = TextEditingController();
  final latC = TextEditingController();
  final lngC = TextEditingController();

  // Teacher fields
  final subjectsC = TextEditingController();
  final classLevelsC = TextEditingController();
  final universityC = TextEditingController();
  final departmentC = TextEditingController();
  final jobTitleC = TextEditingController();
  final salaryMinC = TextEditingController();
  final salaryMaxC = TextEditingController();
  final availDaysC = TextEditingController();
  final availTimeC = TextEditingController();
  final aboutC = TextEditingController();

  // NID
  String? nidCardImageUrl;

  // CV (for teachers)
  File? cvFile;
  String? cvFileUrl;

  // Profile image (local)
  File? profileImageFile;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    nameC.dispose();
    phoneC.dispose();
    classLevelC.dispose();
    schoolC.dispose();
    guardianNameC.dispose();
    guardianPhoneC.dispose();
    guardianNidC.dispose();
    cityC.dispose();
    areaC.dispose();
    latC.dispose();
    lngC.dispose();
    subjectsC.dispose();
    classLevelsC.dispose();
    universityC.dispose();
    departmentC.dispose();
    jobTitleC.dispose();
    salaryMinC.dispose();
    salaryMaxC.dispose();
    availDaysC.dispose();
    availTimeC.dispose();
    aboutC.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => loading = true);

    try {
      final me = await auth.apiClient.get("/auth/me");
      user = me["user"];

      // Fill basic
      nameC.text = user?["name"] ?? "";
      phoneC.text = user?["phone"] ?? "";

      // Load profile (may be null on first load, always null for admins)
      if (auth.role == "admin") {
        profile = null; // Admins don't have profiles
      } else {
        try {
          final p = await profileService.getMyProfile();
          profile = p["profile"];
        } catch (e) {
          print("Profile load error (may be first time): $e");
          profile = null;
        }
      }

      // Load tuitions for students and teachers
      if (auth.role == "student") {
        try {
          myTuitions = await tuitionService.getMyPosts();
        } catch (e) {
          print("Error loading my tuitions: $e");
          myTuitions = [];
        }
      }

      if (auth.role == "teacher") {
        try {
          myApplications = await tuitionService.myApplications();
        } catch (e) {
          print("Error loading my applications: $e");
          myApplications = [];
        }
      }

      if (auth.role == "student" && profile != null) {
        classLevelC.text = profile?["classLevel"] ?? "";
        schoolC.text = profile?["school"] ?? "";
        guardianNameC.text = profile?["guardianName"] ?? "";
        guardianPhoneC.text = profile?["guardianPhone"] ?? "";
        guardianNidC.text = profile?["guardianNidNumber"] ?? "";
        cityC.text = profile?["location"]?["city"] ?? "";
        areaC.text = profile?["location"]?["area"] ?? "";

        final coordinates = profile?["location"]?["coordinates"] ?? [0, 0];
        lngC.text = coordinates.isNotEmpty ? coordinates[0].toString() : "";
        latC.text = coordinates.length > 1 ? coordinates[1].toString() : "";
      }

      if (auth.role == "teacher" && profile != null) {
        subjectsC.text = (profile?["subjects"] ?? []).join(", ");
        classLevelsC.text = (profile?["classLevels"] ?? []).join(", ");

        universityC.text = profile?["university"] ?? "";
        departmentC.text = profile?["department"] ?? "";
        jobTitleC.text = profile?["jobTitle"] ?? "";

        salaryMinC.text = profile?["expectedSalaryMin"]?.toString() ?? "";
        salaryMaxC.text = profile?["expectedSalaryMax"]?.toString() ?? "";

        cityC.text = profile?["location"]?["city"] ?? "";
        areaC.text = profile?["location"]?["area"] ?? "";

        final coordinates = profile?["location"]?["coordinates"] ?? [0, 0];
        lngC.text = coordinates.isNotEmpty ? coordinates[0].toString() : "";
        latC.text = coordinates.length > 1 ? coordinates[1].toString() : "";

        availDaysC.text = (profile?["availability"]?["days"] ?? []).join(", ");
        availTimeC.text = profile?["availability"]?["timeRange"] ?? "";

        aboutC.text = profile?["about"] ?? "";
        nidCardImageUrl = profile?["nidCardImageUrl"];
        // Load local profile image (if any)
        try {
          final local = await ProfileImageService.instance.getImage();
          if (local != null) profileImageFile = local;
          profileImageUrl = await StorageService.instance.getProfileImage();
        } catch (_) {}
      }
    } catch (e) {
      print("User load error: $e");
      showSnackBar(context, "Failed to load user info", isError: true);
    }

    setState(() => loading = false);
  }

  Future<void> save() async {
    try {
      showSnackBar(context, "Saving...");

      // Save basic profile
      await auth.updateBasicInfo(
        name: nameC.text.trim(),
        phone: phoneC.text.trim(),
      );

      // Prepare location
      final double lat = double.tryParse(latC.text) ?? 0;
      final double lng = double.tryParse(lngC.text) ?? 0;

      final location = {
        "type": "Point",
        "coordinates": [lng, lat],
        "city": cityC.text.trim(),
        "area": areaC.text.trim(),
      };

      if (auth.role == "student") {
        await profileService.updateStudentProfile({
          "classLevel": classLevelC.text.trim(),
          "school": schoolC.text.trim(),
          "guardianName": guardianNameC.text.trim(),
          "guardianPhone": guardianPhoneC.text.trim(),
          "guardianNidNumber": guardianNidC.text.trim(),
          "location": location,
        });
      } else {
        await profileService.updateTeacherProfile({
          "subjects": subjectsC.text
              .split(",")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          "classLevels": classLevelsC.text
              .split(",")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          "university": universityC.text.trim(),
          "department": departmentC.text.trim(),
          "jobTitle": jobTitleC.text.trim(),
          "expectedSalaryMin": int.tryParse(salaryMinC.text) ?? 0,
          "expectedSalaryMax": int.tryParse(salaryMaxC.text) ?? 0,
          "location": location,
          "availability": {
            "days": availDaysC.text
                .split(",")
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            "timeRange": availTimeC.text.trim(),
          },
          "about": aboutC.text.trim(),
          "nidCardImageUrl": nidCardImageUrl,
        });
      }

      showSnackBar(context, "Profile updated!");

      setState(() => editMode = false);
      await load();
    } catch (e) {
      showSnackBar(context, "Save failed", isError: true);
    }
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    // Prevent admins from viewing this tab
    if (auth.role == "admin") {
      return const Center(
        child: Text("Admin users don't have student/teacher profiles"),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: editMode ? 80 : 0), // Space for top buttons
              header(),
              const SizedBox(height: 20),

              infoCard("Email", user?["email"] ?? "-", Icons.email),
              infoCard("Phone", user?["phone"] ?? "-", Icons.phone),

              const SizedBox(height: 20),

              if (auth.role == "student") studentSection(),
              if (auth.role == "teacher") teacherSection(),

              const SizedBox(height: 30),
              const SizedBox(height: 40),
            ],
          ),
        ),
        // Save/Cancel buttons at top (sticky)
        if (editMode)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await save();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 44),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      setState(() => editMode = false);
                      load();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(120, 44),
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5A6FF0), Color(0xFF6C8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 8),
              GestureDetector(
                onTap: editMode ? _pickProfileImage : null,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: profileImageFile != null
                        ? Image.file(
                            profileImageFile!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : (profileImageUrl != null &&
                              profileImageUrl!.isNotEmpty)
                        ? Image.network(
                            profileImageUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.person, size: 60, color: Colors.indigo),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (editMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: _pickAndCropProfileImage,
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Change'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed:
                            profileImageFile != null ||
                                (profileImageUrl != null &&
                                    profileImageUrl!.isNotEmpty)
                            ? _removeProfileImage
                            : null,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Remove',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              if (editMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: nameC,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Full name',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                )
              else
                Text(
                  user?["name"] ?? "Unknown User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                auth.role?.toUpperCase() ?? "",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
            ],
          ),

          // Overflow menu (3-dot) top-right
          Positioned(
            right: 8,
            top: 8,
            child: PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (val) async {
                if (val == 'edit') {
                  setState(() => editMode = true);
                } else if (val == 'logout') {
                  await auth.logout();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (_) => false,
                  );
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
                const PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
              icon: const Icon(Icons.more_vert, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoCard(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueGrey),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(value),
          ],
        ),
      ),
    );
  }

  Widget studentSection() {
    return Column(
      children: [
        sectionBox("Student Profile", [
          field("Class Level", classLevelC),
          field("School/College Name", schoolC),
          const SizedBox(height: 16),
          const Text(
            "👨‍👩‍👧 Guardian Information",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          field("Guardian's Name", guardianNameC),
          field("Guardian's Phone", guardianPhoneC),
          field("Guardian's NID Number", guardianNidC),
          const SizedBox(height: 16),
          const Text(
            "📍 Location",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          _improvedLocationPicker(),
        ]),
        const SizedBox(height: 20),
        _tuitionCardSection(),
      ],
    );
  }

  Widget teacherSection() {
    return Column(
      children: [
        sectionBox("Teacher Profile", [
          field("Subjects", subjectsC),
          field("Class Levels", classLevelsC),
          field("University", universityC),
          field("Department", departmentC),
          field("Job Title", jobTitleC),
          field("Min Salary", salaryMinC),
          field("Max Salary", salaryMaxC),
          _improvedLocationPicker(),
          field("Available Days", availDaysC),
          field("Available Time", availTimeC),
          field("About", aboutC),
          const SizedBox(height: 16),
          _cvFileSection(),
          const SizedBox(height: 16),
          _nidCardSection(),
        ]),
        const SizedBox(height: 20),
        _myTuitionsCardSection(),
      ],
    );
  }

  Widget _improvedLocationPicker() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📍 Set Your Location",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          // Search/Address input
          TextField(
            controller: cityC,
            decoration: InputDecoration(
              hintText: "Search address or city name...",
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => cityC.clear(),
              ),
            ),
            onChanged: (value) {
              // Could add autocomplete here
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: areaC,
                  decoration: InputDecoration(
                    hintText: "Area/District",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text("Auto-detect"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Map preview button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openMapPicker,
              icon: const Icon(Icons.map),
              label: const Text("Pinpoint on Map"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.indigo),
              ),
            ),
          ),
          if (latC.text.isNotEmpty && lngC.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Location",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Lat: ${latC.text}, Lng: ${lngC.text}",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      showSnackBar(context, "Getting your current location...");
      // In a real app, you would use geolocator package
      // For now, show a placeholder
      showSnackBar(context, "Location auto-detect requires GPS permissions");
    } catch (e) {
      showSnackBar(context, "Error: $e", isError: true);
    }
  }

  Future<void> _openMapPicker() async {
    showSnackBar(
      context,
      "Map picker coming soon - for now, enter coordinates manually",
    );
    // In a real app, you would open flutter_map or google_maps
  }

  Widget _cvFileSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📄 Curriculum Vitae (CV)",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (cvFile != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.file_present, color: Colors.indigo.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cvFile!.path.split('/').last,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (editMode)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => cvFile = null),
                    ),
                ],
              ),
            )
          else if (cvFileUrl != null && cvFileUrl!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "CV Uploaded",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          if (editMode)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickCVFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text("Upload CV"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              (cvFile != null || (cvFileUrl != null && cvFileUrl!.isNotEmpty))
                  ? "✅ CV Uploaded"
                  : "❌ CV Not Uploaded",
              style: TextStyle(
                fontSize: 13,
                color:
                    (cvFile != null ||
                        (cvFileUrl != null && cvFileUrl!.isNotEmpty))
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickCVFile() async {
    try {
      final ImagePicker picker = ImagePicker();
      // Can pick image or document
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        setState(() {
          cvFile = File(file.path);
        });
      }
    } catch (e) {
      showSnackBar(context, "Error picking CV: $e", isError: true);
    }
  }

  Widget _nidCardSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "NID Card Verification",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (nidCardImageUrl != null && nidCardImageUrl!.isNotEmpty)
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(nidCardImageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 10),
          if (editMode)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickNIDImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Upload NID Image"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              nidCardImageUrl != null && nidCardImageUrl!.isNotEmpty
                  ? "✅ NID Card Uploaded"
                  : "❌ NID Card Not Uploaded",
              style: TextStyle(
                fontSize: 13,
                color: nidCardImageUrl != null && nidCardImageUrl!.isNotEmpty
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickNIDImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Save path locally for NID preview. Backend upload handled on save().
        setState(() {
          nidCardImageUrl = image.path;
        });
        showSnackBar(context, "Image selected. Save to update profile.");
      }
    } catch (e) {
      showSnackBar(context, "Failed to pick image", isError: true);
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final file = File(image.path);
        await ProfileImageService.instance.saveImage(file);
        await StorageService.instance.saveProfileImage(file.path);
        setState(() {
          profileImageFile = file;
          profileImageUrl = file.path;
        });
        showSnackBar(context, 'Profile image selected. Save to persist.');
      }
    } catch (e) {
      showSnackBar(context, 'Failed to pick image', isError: true);
    }
  }

  Future<void> _pickAndCropProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.indigo,
            toolbarWidgetColor: Colors.white,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      if (cropped == null) return;

      final file = File(cropped.path);
      await ProfileImageService.instance.saveImage(file);
      await StorageService.instance.saveProfileImage(file.path);
      setState(() {
        profileImageFile = file;
        profileImageUrl = file.path;
      });
      showSnackBar(
        context,
        'Profile image updated. Save to persist to server.',
      );
    } catch (e) {
      showSnackBar(context, 'Failed to pick/crop image', isError: true);
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      await ProfileImageService.instance.deleteImage();
      await StorageService.instance.clearProfileImage();
      setState(() {
        profileImageFile = null;
        profileImageUrl = null;
      });
      showSnackBar(context, 'Profile image removed. Save to persist.');
    } catch (e) {
      showSnackBar(context, 'Failed to remove image', isError: true);
    }
  }

  Widget sectionBox(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _tuitionCardSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "📚 My Tuition Posts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: editMode || auth.role != "student"
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TuitionCreatePage(),
                            ),
                          ).then((_) {
                            load(); // Reload after returning
                          });
                        },
                  icon: const Icon(Icons.add),
                  label: const Text("Post"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (myTuitions.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Text(
                    "No tuition posts yet. Create your first tuition post!",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              )
            else
              Column(
                children: myTuitions.map((tuition) {
                  final status = tuition["status"] ?? "pending";
                  final statusColor = status == "approved"
                      ? Colors.green
                      : status == "rejected"
                      ? Colors.red
                      : Colors.orange;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                tuition["title"] ?? "Untitled",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(
                                  (0.2 * 255).round(),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Class: ${tuition["classLevel"] ?? "N/A"} | Salary: ${tuition["salaryMin"]}-${tuition["salaryMax"]}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _myTuitionsCardSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📖 My Applications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (myApplications.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Text(
                    "No applications yet. Start applying to tuition posts!",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              )
            else
              Column(
                children: myApplications.map((app) {
                  final post = app["postId"] ?? {};
                  final status = app["status"] ?? "pending";
                  final statusColor = status == "approved"
                      ? Colors.green
                      : status == "rejected"
                      ? Colors.red
                      : Colors.orange;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                post["title"] ?? "Untitled",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(
                                  (0.2 * 255).round(),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Class: ${post["classLevel"] ?? "N/A"} | Salary: ${post["salaryMin"]}-${post["salaryMax"]}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        enabled: editMode,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget saveOrEditButtons() {
    return Column(
      children: [
        if (editMode)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await save();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, 48),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() => editMode = false);
                  load();
                },
                child: const Text('Cancel'),
              ),
            ],
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
