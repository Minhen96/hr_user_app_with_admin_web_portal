import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import '../theme/theme_provider.dart';

// Services (will be uncommented as features are migrated)
// import '../services/notification_service.dart';

// Features - Auth
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// Features - Equipment (will be uncommented after migration)
// import '../../features/equipment/data/datasources/equipment_remote_datasource.dart';
// import '../../features/equipment/data/repositories/equipment_repository_impl.dart';
// import '../../features/equipment/domain/repositories/equipment_repository.dart';
// import '../../features/equipment/domain/usecases/get_equipment_requests.dart';
// import '../../features/equipment/domain/usecases/create_equipment_request.dart';
// import '../../features/equipment/presentation/providers/equipment_provider.dart';

final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  // ============================================================================
  // CORE
  // ============================================================================

  // HTTP Client
  sl.registerLazySingleton(() => http.Client());

  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Secure Storage
  sl.registerLazySingleton(() => SecureStorage());

  // API Client
  sl.registerLazySingleton(() => ApiClient(
        client: sl(),
        secureStorage: sl(),
      ));

  // Theme Provider
  sl.registerLazySingleton(() => ThemeProvider());

  // Notification Service (uncomment when needed)
  // sl.registerLazySingleton(() => NotificationService());

  // ============================================================================
  // FEATURES
  // ============================================================================

  // ---------------------------------------------------------------------------
  // AUTH FEATURE
  // ---------------------------------------------------------------------------

  // Providers
  sl.registerFactory(() => AuthProvider(
        loginUseCase: sl(),
        logoutUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl(),
      sharedPreferences: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // EQUIPMENT FEATURE (uncomment after migration)
  // ---------------------------------------------------------------------------
  /*
  // Providers
  sl.registerFactory(() => EquipmentProvider(
        getEquipmentRequestsUseCase: sl(),
        createEquipmentRequestUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => GetEquipmentRequests(repository: sl()));
  sl.registerLazySingleton(() => CreateEquipmentRequest(repository: sl()));

  // Repository
  sl.registerLazySingleton<EquipmentRepository>(
    () => EquipmentRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<EquipmentRemoteDataSource>(
    () => EquipmentRemoteDataSourceImpl(client: sl()),
  );
  */

  // ---------------------------------------------------------------------------
  // DOCUMENTS FEATURE (uncomment after migration)
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // LEAVE FEATURE (uncomment after migration)
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // TRAINING FEATURE (uncomment after migration)
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // MOMENTS FEATURE (uncomment after migration)
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // ATTENDANCE FEATURE (uncomment after migration)
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // CALENDAR FEATURE (uncomment after migration)
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // HANDBOOK FEATURE (uncomment after migration)
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // CHANGE REQUEST FEATURE (uncomment after migration)
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // PROFILE FEATURE (uncomment after migration)
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // HOME FEATURE (uncomment after migration)
  // ---------------------------------------------------------------------------
}

