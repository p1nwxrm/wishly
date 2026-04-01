import 'package:get_it/get_it.dart';

import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../storage/secure_storage_service.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../data/repositories/gift_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../data/repositories/tag_repository.dart';
import '../../data/repositories/booking_repository.dart';

import '../../presentation/blocs/auth/auth_bloc.dart';

// Global instance of GetIt service locator
final getIt = GetIt.instance;

// Function to initialize all dependencies before app starts
Future<void> setupDependencies() async {
  // 1. Core Services
  // Register SecureStorageService as a lazy singleton
  // It will be created only once when first requested
  getIt.registerLazySingleton<SecureStorageService>(
        () => SecureStorageService(),
  );

  // 2. Network
  // Register ApiClient, injecting the SecureStorageService into it
  // getIt<SecureStorageService>() automatically finds the instance we registered above
  getIt.registerLazySingleton<ApiClient>(
        () => ApiClient(getIt<SecureStorageService>()),
  );

  // Expose the Dio instance directly for convenience
  // Repositories will just ask for Dio, not the whole ApiClient
  getIt.registerLazySingleton<Dio>(
        () => getIt<ApiClient>().dio,
  );

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

  // 4. BLoCs
  // Register AuthBloc using a factory
  // This ensures a fresh instance is created if the screen is reopened
  getIt.registerFactory<AuthBloc>(
        () => AuthBloc(getIt<AuthRepository>()),
  );
}