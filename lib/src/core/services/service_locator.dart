import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/admin_service.dart';
import 'package:test_app/src/core/services/announcement_service.dart';
import 'package:test_app/src/core/services/top_teachers_service.dart';

import '../network/api_client.dart';
import 'auth_service.dart';
import 'profile_service.dart';
import 'tuition_service.dart';
import 'chat_service.dart';
import 'demo_service.dart';
import 'matches_service.dart';
import 'search_service.dart';
import 'notification_service.dart';
import 'storage_service.dart';

final sl = GetIt.instance;

Future<void> initServices() async {
  // STORAGE
  sl.registerLazySingleton<StorageService>(() => StorageService.instance);

  // API CLIENT
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(storage: sl<StorageService>()),
  );

  // AUTH SERVICE
  sl.registerLazySingleton<AuthService>(
    () =>
        AuthService(apiClient: sl<ApiClient>(), storage: sl<StorageService>()),
  );
  sl.registerLazySingleton<AdminService>(() => AdminService(sl<ApiClient>()));
  // PROFILE SERVICE
  sl.registerLazySingleton<ProfileService>(
    () => ProfileService(sl<ApiClient>()),
  );

  // TUITION SERVICE
  sl.registerLazySingleton<TuitionService>(
    () => TuitionService(api: sl<ApiClient>()),
  );

  // CHAT SERVICE
  sl.registerLazySingleton<ChatService>(
    () => ChatService(api: sl<ApiClient>()),
  );

  // DEMO SERVICE
  sl.registerLazySingleton<DemoService>(
    () => DemoService(apiClient: sl<ApiClient>()),
  );

  // MATCHES SERVICE
  sl.registerLazySingleton<MatchesService>(
    () => MatchesService(apiClient: sl<ApiClient>()),
  );

  // SEARCH SERVICE
  sl.registerLazySingleton<SearchService>(() => SearchService(sl<ApiClient>()));

  // NOTIFICATION SERVICE
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(apiClient: sl<ApiClient>()),
  );

  // ANNOUNCEMENT SERVICE
  sl.registerLazySingleton<AnnouncementService>(
    () => AnnouncementService(apiClient: sl<ApiClient>()),
  );

  // TOP TEACHERS SERVICE
  sl.registerLazySingleton<TopTeachersService>(
    () => TopTeachersService(apiClient: sl<ApiClient>()),
  );
}
