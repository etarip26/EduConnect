import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  /// Global singleton
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _sp async =>
      _prefs ??= await SharedPreferences.getInstance();

  // =====================================================
  // TOKEN
  // =====================================================

  Future<void> saveToken(String token) async {
    print("💾 saveToken() CALLED → $token");

    final sp = await _sp;
    final ok = await sp.setString('token', token);

    print("💾 TOKEN SAVED RESULT: $ok");

    final verify = sp.getString('token');
    print("🔍 Token stored right now → $verify");
  }

  Future<String?> getToken() async {
    final sp = await _sp;
    return sp.getString('token');
  }

  // =====================================================
  // ROLE
  // =====================================================

  Future<void> saveRole(String role) async {
    final sp = await _sp;
    await sp.setString('role', role);
  }

  Future<String?> getRole() async {
    final sp = await _sp;
    return sp.getString('role');
  }

  // =====================================================
  // USER NAME (Full Name)
  // =====================================================

  Future<void> saveUserName(String name) async {
    final sp = await _sp;
    await sp.setString('userName', name);
  }

  Future<String?> getUserName() async {
    final sp = await _sp;
    return sp.getString('userName');
  }
  // =====================================================
  // PROFILE IMAGE URL
  // =====================================================

  Future<void> saveProfileImage(String url) async {
    final sp = await _sp;
    await sp.setString('profileImageUrl', url);
  }

  Future<String?> getProfileImage() async {
    final sp = await _sp;
    return sp.getString('profileImageUrl');
  }

  Future<void> clearProfileImage() async {
    final sp = await _sp;
    await sp.remove('profileImageUrl');
  }

  // =====================================================
  // CLEAR ALL ON LOGOUT
  // =====================================================
  Future<void> clearTokenAndRole() async {
    final sp = await _sp;
    await sp.remove('token');
    await sp.remove('role');
    await sp.remove('userName');
    await sp.remove('profileImageUrl');
  }
}
