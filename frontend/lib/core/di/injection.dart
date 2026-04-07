import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../logger/app_logger.dart'; //
import '../api/api_client.dart';
import '../storage/secure_storage_service.dart';
import '../router/auth_guard.dart';
import '../router/app_router.dart';
import '../../data/repositories/repositories.dart';
import '../../presentation/blocs/blocs.dart';

// Global instance of GetIt service locator
final getIt = GetIt.instance;

// Function to initialize all dependencies before app starts
Future<void> setupDependencies() async {
  // 1. Logger
  // Register Talker first so other dependencies can use it
  getIt.registerSingleton<Talker>(setupLogger());

  // 2. Core Services
  // Register SecureStorageService as a lazy singleton
  // It will be created only once when first requested
  getIt.registerLazySingleton<SecureStorageService>(
        () => SecureStorageService(),
  );

  // 3. Router
  // Register AuthGuard injecting SecureStorageService and Talker
  getIt.registerSingleton<AuthGuard>(
    AuthGuard(getIt<SecureStorageService>(), getIt<Talker>()),
  );

  // Register AppRouter injecting AuthGuard
  getIt.registerSingleton<AppRouter>(
    AppRouter(getIt<AuthGuard>()),
  );

  // 4. Network
  // Register ApiClient, injecting the SecureStorageService into it
  // getIt<SecureStorageService>() automatically finds the instance we registered above
  getIt.registerLazySingleton<ApiClient>(
        () => ApiClient(
      getIt<SecureStorageService>(),
      getIt<Talker>(),
          onUnauthorized: () {
            // This callback is triggered by the Interceptor when tokens die.
            // We tell the global AuthBloc to log the user out.
            getIt<AuthBloc>().add(LogoutRequested());
          },
    ),
  );

  // Expose the Dio instance directly for convenience
  // Repositories will just ask for Dio, not the whole ApiClient
  getIt.registerLazySingleton<Dio>(
        () => getIt<ApiClient>().dio,
  );

  // 5. Repositories
  // Register AuthRepository, injecting Dio and SecureStorageService from GetIt
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepository(getIt<Dio>(), getIt<SecureStorageService>()),
  );

  // Register WishlistRepository, injecting Dio from GetIt
  getIt.registerLazySingleton<WishlistRepository>(
        () => WishlistRepository(getIt<Dio>()),
  );

  // Register GiftRepository, injecting Dio from GetIt
  getIt.registerLazySingleton<GiftRepository>(
        () => GiftRepository(getIt<Dio>()),
  );

  // Register UserRepository, injecting Dio from GetIt
  getIt.registerLazySingleton<UserRepository>(
        () => UserRepository(getIt<Dio>()),
  );

  // Register SubscriptionRepository, injecting Dio from GetIt
  getIt.registerLazySingleton<SubscriptionRepository>(
        () => SubscriptionRepository(getIt<Dio>()),
  );

  // Register TagRepository, injecting Dio from GetIt
  getIt.registerLazySingleton<TagRepository>(
        () => TagRepository(getIt<Dio>()),
  );

  // Register BookingRepository, injecting Dio from GetIt
  getIt.registerLazySingleton<BookingRepository>(
        () => BookingRepository(getIt<Dio>()),
  );

  // Register AuthBloc using a factory
  // This ensures a fresh instance is created if the screen is reopened
  getIt.registerFactory<AuthBloc>(
        () => AuthBloc(
      getIt<AuthRepository>(),
      getIt<Talker>(),
    ),
  );

  // Register WishlistBloc
  getIt.registerFactory<WishlistBloc>(
        () => WishlistBloc(
      getIt<WishlistRepository>(),
      getIt<Talker>(),
    ),
  );

  // Register GiftBloc
  getIt.registerFactory<GiftBloc>(
        () => GiftBloc(
      getIt<GiftRepository>(),
      getIt<Talker>(),
    ),
  );

  // Register UserBloc
  getIt.registerFactory<UserBloc>(
        () => UserBloc(
      getIt<UserRepository>(),
      getIt<Talker>(),
    ),
  );

  // Register SubscriptionBloc
  getIt.registerFactory<SubscriptionBloc>(
        () => SubscriptionBloc(
      getIt<SubscriptionRepository>(),
      getIt<Talker>(),
    ),
  );

  // Register BookingBloc
  getIt.registerFactory<BookingBloc>(
        () => BookingBloc(
      getIt<BookingRepository>(),
      getIt<Talker>(),
    ),
  );

  // Register TagBloc
  getIt.registerFactory<TagBloc>(
        () => TagBloc(
      getIt<TagRepository>(),
      getIt<Talker>(),
    ),
  );
}
