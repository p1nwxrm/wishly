import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../logger/app_logger.dart';
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
            // This tells the UI to kick the user out WITHOUT trying to call /users/logout on the backend.
            getIt<AuthBloc>().add(SessionExpired());
          },
    ),
  );

  // Expose the Dio instance directly for convenience
  // Repositories will just ask for Dio, not the whole ApiClient
  getIt.registerLazySingleton<Dio>(
        () => getIt<ApiClient>().dio,
  );

  // 5. Repositories
  // Register AuthRepository
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepository(getIt<Dio>(), getIt<SecureStorageService>()),
  );

  // Register WishlistRepository
  getIt.registerLazySingleton<WishlistRepository>(
        () => WishlistRepository(getIt<Dio>()),
  );

  // Register GiftRepository
  getIt.registerLazySingleton<GiftRepository>(
        () => GiftRepository(getIt<Dio>()),
  );

  // Register UserRepository
  getIt.registerLazySingleton<UserRepository>(
        () => UserRepository(getIt<Dio>()),
  );

  // Register SubscriptionRepository
  getIt.registerLazySingleton<SubscriptionRepository>(
        () => SubscriptionRepository(getIt<Dio>()),
  );

  // Register TagRepository
  getIt.registerLazySingleton<TagRepository>(
        () => TagRepository(getIt<Dio>()),
  );

  // Register BookingRepository
  getIt.registerLazySingleton<BookingRepository>(
        () => BookingRepository(getIt<Dio>()),
  );

  // Register FeedRepository
  getIt.registerLazySingleton<FeedRepository>(
        () => FeedRepository(getIt<Dio>()),
  );

  // 6. BLoCs
  // --- SINGLETONS ---
  // Register AuthBloc
  getIt.registerLazySingleton<AuthBloc>(
        () => AuthBloc(
      getIt<AuthRepository>(),
      getIt<Talker>(),
    ),
  );

  // Register UserBloc
  getIt.registerLazySingleton<UserBloc>(
        () => UserBloc(
      getIt<UserRepository>(),
      getIt<Talker>(),
    ),
  );

  // Register BookingBloc
  getIt.registerLazySingleton<BookingBloc>(
        () => BookingBloc(
      getIt<BookingRepository>(),
      getIt<Talker>(),
    ),
  );

  // Register FeedBloc
  getIt.registerLazySingleton<FeedBloc>(
        () => FeedBloc(
      getIt<FeedRepository>(),
      getIt<Talker>(),
    ),
  );

  // --- FACTORIES ---
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

  // Register ProfileBloc
  getIt.registerFactory<ProfileBloc>(
        () => ProfileBloc(
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

  // Register TagBloc
  getIt.registerFactory<TagBloc>(
        () => TagBloc(
      getIt<TagRepository>(),
      getIt<Talker>(),
    ),
  );
}
