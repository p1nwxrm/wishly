import 'package:auto_route/auto_route.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../storage/secure_storage_service.dart';
import 'app_router.dart';

// Guard to protect routes that require authentication
class AuthGuard extends AutoRouteGuard {
  final SecureStorageService _storage;
  final Talker _talker;

  AuthGuard(this._storage, this._talker);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    // Fast local check for access token
    final token = await _storage.getAccessToken();
    final bool isAuthenticated = token != null && token.isNotEmpty;

    if (isAuthenticated) {
      // User has a token, allow them to proceed to the requested screen
      resolver.next(true);
    } else {
      // Log the rejected navigation attempt
      _talker.warning('AuthGuard prevented navigation to ${resolver.route.name}');

      // User is not authenticated, redirect to WelcomeScreen using the router
      router.replace(const WelcomeRoute());

      // Abort the original requested navigation
      resolver.next(false);
    }
  }
}