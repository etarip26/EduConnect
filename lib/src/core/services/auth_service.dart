import 'package:test_app/src/config/api_paths.dart';
import 'package:test_app/src/core/models/user.dart';
import 'package:test_app/src/core/network/api_client.dart';
import 'package:test_app/src/core/services/storage_service.dart';

class AuthService {
  final ApiClient apiClient;
  final StorageService storage;

  AuthService({required this.apiClient, required this.storage});

  UserModel? _user;

  UserModel? get user => _user;
  String? get role => _user?.role;
  String? get name => _user?.name;
  bool get isVerified => _user?.isEmailVerified ?? false;

  // -------------------------------------------------------------
  // LOGIN
  // -------------------------------------------------------------
  Future<void> login(String email, String password) async {
    print("🔵 LOGIN() CALLED");

    final res = await apiClient.post(ApiPaths.login, {
      'email': email,
      'password': password,
    });

    print("🔵 LOGIN RESPONSE RAW → $res");

    final token = res['token'];
    final userJson = res['user'];

    print("🟡 Extracted token: $token");
    print("🟡 Extracted user JSON: $userJson");

    if (token == null || userJson == null) {
      print("❌ ERROR: token or user missing");
      throw Exception("Unexpected login response.");
    }

    print("💾 Saving token...");
    await storage.saveToken(token);

    print("💾 Token saved OK!");

    _user = UserModel.fromJson(userJson);

    await storage.saveUserName(_user!.name);
    await storage.saveRole(_user!.role);

    print("✅ Login finished. User: ${_user!.name}, role: ${_user!.role}");
  }

  // -------------------------------------------------------------
  // REGISTER
  // -------------------------------------------------------------
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    final res = await apiClient.post(ApiPaths.register, {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'phone': phone,
    });

    if (res['token'] != null && res['user'] != null) {
      await storage.saveToken(res['token']);
      _user = UserModel.fromJson(res['user']);

      await storage.saveUserName(_user!.name);
      await storage.saveRole(_user!.role);
    }
  }

  // -------------------------------------------------------------
  // REQUEST OTP
  // -------------------------------------------------------------
  Future<void> requestOtp() async {
    await apiClient.post(ApiPaths.requestOtp);
  }

  // -------------------------------------------------------------
  // VERIFY OTP
  // -------------------------------------------------------------
  Future<void> verifyOtp(String code) async {
    final res = await apiClient.post(ApiPaths.verifyOtp, {'code': code});

    if (res['user'] != null) {
      _user = UserModel.fromJson(res['user']);

      await storage.saveUserName(_user!.name);
      await storage.saveRole(_user!.role);
    }
  }

  // -------------------------------------------------------------
  // CHECK /ME
  // -------------------------------------------------------------
  Future<bool> checkEmailVerificationStatus() async {
    final res = await apiClient.get(ApiPaths.me);
    final userJson = res['user'];

    if (userJson == null) return false;

    _user = UserModel.fromJson(userJson);

    await storage.saveUserName(_user!.name);
    await storage.saveRole(_user!.role);

    return _user!.isEmailVerified;
  }

  // -------------------------------------------------------------
  // UPDATE BASIC INFO (name + phone)
  // -------------------------------------------------------------
  Future<void> updateBasicInfo({
    required String name,
    required String phone,
  }) async {
    final res = await apiClient.put(ApiPaths.updateBasic, {
      'name': name,
      'phone': phone,
    });

    if (res['user'] != null) {
      _user = UserModel.fromJson(res['user']);
      await storage.saveUserName(_user!.name);
    }
  }

  // -------------------------------------------------------------
  // HYDRATE (only name + role from local storage)
  // -------------------------------------------------------------
  Future<void> hydrateFromStorage() async {
    print("🔵 hydrateFromStorage() called");

    try {
      final savedToken = await storage.getToken();
      final savedName = await storage.getUserName();
      final savedRole = await storage.getRole();

      print("🔹 Stored token: $savedToken");
      print("🔹 Stored name: $savedName");
      print("🔹 Stored role: $savedRole");

      if (savedToken == null) {
        print("❌ No token found — user is NOT logged in");
        _user = null;
        return;
      }

      // If we have a token, ask backend who this user is
      print("➡️ Calling /api/auth/me to fetch real user...");
      final res = await apiClient.get(ApiPaths.me);

      if (res["user"] != null) {
        _user = UserModel.fromJson(res["user"]);

        print("✅ Hydrated REAL user from backend:");
        print("   ID: ${_user!.id}");
        print("   Name: ${_user!.name}");
        print("   Role: ${_user!.role}");
        print("   Verified: ${_user!.isEmailVerified}");

        // refresh cached name + role
        await storage.saveUserName(_user!.name);
        await storage.saveRole(_user!.role);
        return;
      }

      print("⚠️ /me returned no user. Falling back to saved local values.");

      if (savedName != null && savedRole != null) {
        _user = UserModel(
          id: "",
          name: savedName,
          email: "",
          phone: "",
          role: savedRole,
          isEmailVerified: false,
          isSuspended: false,
        );

        print("✅ Hydrated LOCAL user only:");
        print("   Name: $savedName");
        print("   Role: $savedRole");
      } else {
        print("❌ No usable local data found.");
        _user = null;
      }
    } catch (e, s) {
      print("🔥 hydrateFromStorage FAILED:");
      print("Error: $e");
      print("Stack: $s");
      _user = null;
    }
  }

  void setUserFromJson(Map<String, dynamic> json) {
    _user = UserModel.fromJson(json);
    storage.saveUserName(_user!.name);
    storage.saveRole(_user!.role);
  }

  // -------------------------------------------------------------
  // LOGOUT
  // -------------------------------------------------------------
  Future<void> logout() async {
    await storage.clearTokenAndRole();
    _user = null;
  }
}
