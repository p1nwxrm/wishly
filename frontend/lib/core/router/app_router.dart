import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'auth_guard.dart';

import '../../data/models/user_models.dart';
import '../../presentation/screens/screens.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  final AuthGuard authGuard;

  AppRouter(this.authGuard);

  @override
  List<AutoRoute> get routes => [
    // --- Initial Entry Point ---
    AutoRoute(page: SplashRoute.page, initial: true),

    // --- Authentication Flow ---
    AutoRoute(page: WelcomeRoute.page),
    AutoRoute(page: SignInRoute.page),
    AutoRoute(page: SignUpCredentialsRoute.page),
    AutoRoute(page: SignUpProfileRoute.page),

    // --- Main Layout with Bottom Navigation Bar ---
    AutoRoute(
      page: RootRoute.page,
      guards: [authGuard],
      children: [
        AutoRoute(page: FeedRoute.page),
        AutoRoute(page: SearchRoute.page),
        AutoRoute(page: MyProfileRoute.page),
      ],
    ),

    // --- Other Screens ---
    AutoRoute(
      guards: [authGuard],
      page: EditProfileRoute.page,
    ),
    AutoRoute(
        guards: [authGuard],
        page: PublicProfileRoute.page
    ),
    AutoRoute(
        guards: [authGuard],
        page: ConnectionsRoute.page
    ),
    AutoRoute(
        guards: [authGuard],
        page: WishlistDetailsRoute.page
    ),
  ];
}