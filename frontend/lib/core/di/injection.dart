import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../presentation/blocs/blocs.dart';
import '../../data/repositories/repositories.dart';
import '../api/api_client.dart';
import '../logger/app_logger.dart';
import '../storage/secure_storage_service.dart';
import '../router/app_router.dart';
import '../router/auth_guard.dart';

// Global instance of GetIt service locator
final getIt = GetIt.instance;

// Function to initialize all dependencies before the app starts
Future<void> setupDependencies() async {

  // ==========================================
  // 1. LOGGER
  // ==========================================

  // Register Talker first so other dependencies can use it for logging
  getIt.registerSingleton<Talker>(setupLogger());


  // ==========================================
  // 2. CORE SERVICES
  // ==========================================

  // Register SecureStorageService as a lazy singleton.
  // It will be instantiated only once when it is first requested.
  getIt.registerLazySingleton<SecureStorageService>(
        () => SecureStorageService(),
  );


  // ==========================================
  // 3. ROUTING
  // ==========================================

  // Register AuthGuard injecting SecureStorageService and Talker
  getIt.registerSingleton<AuthGuard>(
    AuthGuard(getIt<SecureStorageService>(), getIt<Talker>()),
  );

  // Register AppRouter injecting AuthGuard
  getIt.registerSingleton<AppRouter>(
    AppRouter(getIt<AuthGuard>()),
  );


  // ==========================================
  // 4. NETWORK
  // ==========================================

  // Register ApiClient, injecting the SecureStorageService into it.
  getIt.registerLazySingleton<ApiClient>(
        () => ApiClient(
      getIt<SecureStorageService>(),
      getIt<Talker>(),
      onUnauthorized: () {
        // This triggers the UI to log the user out directly
        // without attempting a /users/logout call on the backend.
        getIt<AuthBloc>().add(SessionExpired());
      },
    ),
  );

  // Expose the Dio instance directly for convenience.
  // Repositories will only require Dio, not the entire ApiClient.
  getIt.registerLazySingleton<Dio>(
        () => getIt<ApiClient>().dio,
  );


  // ==========================================
  // 5. REPOSITORIES
  // ==========================================

  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepository(
            getIt<Dio>(),
            getIt<SecureStorageService>()
        ),
  );

  getIt.registerLazySingleton<BookingRepository>(
        () => BookingRepository(getIt<Dio>()),
  );

  getIt.registerLazySingleton<ConnectionsRepository>(
        () => ConnectionsRepository(getIt<Dio>()),
  );

  // Merged Feed and Search logic into a single DiscoverRepository
  getIt.registerLazySingleton<DiscoverRepository>(
        () => DiscoverRepository(getIt<Dio>()),
  );

  getIt.registerLazySingleton<GiftRepository>(
        () => GiftRepository(getIt<Dio>()),
  );

  getIt.registerLazySingleton<UserRepository>(
        () => UserRepository(getIt<Dio>()),
  );

  getIt.registerLazySingleton<WishlistRepository>(
        () => WishlistRepository(getIt<Dio>()),
  );


  // ==========================================
  // 6. BLOCS (SINGLETONS)
  // State that needs to persist across the app lifecycle
  // ==========================================

  getIt.registerLazySingleton<AuthBloc>(
        () => AuthBloc(
      getIt<AuthRepository>(),
      getIt<Talker>(),
    ),
  );

  getIt.registerLazySingleton<UserBloc>(
        () => UserBloc(
      getIt<UserRepository>(),
      getIt<Talker>(),
    ),
  );

  getIt.registerLazySingleton<BookingBloc>(
        () => BookingBloc(
      getIt<BookingRepository>(),
      getIt<Talker>(),
    ),
  );

  getIt.registerLazySingleton<FeedBloc>(
        () => FeedBloc(
      getIt<DiscoverRepository>(),
      getIt<Talker>(),
    ),
  );

  getIt.registerLazySingleton<MyProfileBloc>(
        () => MyProfileBloc(
      getIt<UserRepository>(),
      getIt<Talker>(),
    ),
  );

  // Register TabRefreshCubit for bottom navigation tap-to-refresh logic
  getIt.registerLazySingleton<TabRefreshCubit>(
        () => TabRefreshCubit(),
  );


  // ==========================================
  // 7. BLOCS (FACTORIES)
  // State that is localized and needs a fresh instance per screen
  // ==========================================

  getIt.registerFactory<WishlistBloc>(
        () => WishlistBloc(
      getIt<WishlistRepository>(),
      getIt<Talker>(),
    ),
  );

  getIt.registerFactory<GiftBloc>(
        () => GiftBloc(
      getIt<GiftRepository>(),
      getIt<Talker>(),
    ),
  );

  getIt.registerFactory<PublicProfileBloc>(
        () => PublicProfileBloc(
      getIt<UserRepository>(),
      getIt<Talker>(),
    ),
  );

  getIt.registerFactory<ConnectionBloc>(
        () => ConnectionBloc(
      getIt<ConnectionsRepository>(),
      getIt<Talker>(),
    ),
  );

  getIt.registerFactory<SearchBloc>(
        () => SearchBloc(
      getIt<DiscoverRepository>(),
      getIt<Talker>(),
    ),
  );
}