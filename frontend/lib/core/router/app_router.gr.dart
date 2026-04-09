// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AddGiftScreen]
class AddGiftRoute extends PageRouteInfo<void> {
  const AddGiftRoute({List<PageRouteInfo>? children})
    : super(AddGiftRoute.name, initialChildren: children);

  static const String name = 'AddGiftRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddGiftScreen();
    },
  );
}

/// generated route for
/// [ConnectionsScreen]
class ConnectionsRoute extends PageRouteInfo<void> {
  const ConnectionsRoute({List<PageRouteInfo>? children})
    : super(ConnectionsRoute.name, initialChildren: children);

  static const String name = 'ConnectionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ConnectionsScreen();
    },
  );
}

/// generated route for
/// [FeedScreen]
class FeedRoute extends PageRouteInfo<void> {
  const FeedRoute({List<PageRouteInfo>? children})
    : super(FeedRoute.name, initialChildren: children);

  static const String name = 'FeedRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FeedScreen();
    },
  );
}

/// generated route for
/// [GiftDetailsScreen]
class GiftDetailsRoute extends PageRouteInfo<void> {
  const GiftDetailsRoute({List<PageRouteInfo>? children})
    : super(GiftDetailsRoute.name, initialChildren: children);

  static const String name = 'GiftDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const GiftDetailsScreen();
    },
  );
}

/// generated route for
/// [MyProfileScreen]
class MyProfileRoute extends PageRouteInfo<void> {
  const MyProfileRoute({List<PageRouteInfo>? children})
    : super(MyProfileRoute.name, initialChildren: children);

  static const String name = 'MyProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyProfileScreen();
    },
  );
}

/// generated route for
/// [OtherUserProfileScreen]
class OtherUserProfileRoute extends PageRouteInfo<void> {
  const OtherUserProfileRoute({List<PageRouteInfo>? children})
    : super(OtherUserProfileRoute.name, initialChildren: children);

  static const String name = 'OtherUserProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OtherUserProfileScreen();
    },
  );
}

/// generated route for
/// [RootScreen]
class RootRoute extends PageRouteInfo<void> {
  const RootRoute({List<PageRouteInfo>? children})
    : super(RootRoute.name, initialChildren: children);

  static const String name = 'RootRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RootScreen();
    },
  );
}

/// generated route for
/// [SearchScreen]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SearchScreen();
    },
  );
}

/// generated route for
/// [SignInScreen]
class SignInRoute extends PageRouteInfo<void> {
  const SignInRoute({List<PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignInScreen();
    },
  );
}

/// generated route for
/// [SignUpCredentialsScreen]
class SignUpCredentialsRoute extends PageRouteInfo<void> {
  const SignUpCredentialsRoute({List<PageRouteInfo>? children})
    : super(SignUpCredentialsRoute.name, initialChildren: children);

  static const String name = 'SignUpCredentialsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignUpCredentialsScreen();
    },
  );
}

/// generated route for
/// [SignUpProfileScreen]
class SignUpProfileRoute extends PageRouteInfo<SignUpProfileRouteArgs> {
  SignUpProfileRoute({
    Key? key,
    required String email,
    required String password,
    List<PageRouteInfo>? children,
  }) : super(
         SignUpProfileRoute.name,
         args: SignUpProfileRouteArgs(
           key: key,
           email: email,
           password: password,
         ),
         initialChildren: children,
       );

  static const String name = 'SignUpProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SignUpProfileRouteArgs>();
      return SignUpProfileScreen(
        key: args.key,
        email: args.email,
        password: args.password,
      );
    },
  );
}

class SignUpProfileRouteArgs {
  const SignUpProfileRouteArgs({
    this.key,
    required this.email,
    required this.password,
  });

  final Key? key;

  final String email;

  final String password;

  @override
  String toString() {
    return 'SignUpProfileRouteArgs{key: $key, email: $email, password: $password}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SignUpProfileRouteArgs) return false;
    return key == other.key &&
        email == other.email &&
        password == other.password;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode ^ password.hashCode;
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [WelcomeScreen]
class WelcomeRoute extends PageRouteInfo<void> {
  const WelcomeRoute({List<PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WelcomeScreen();
    },
  );
}

/// generated route for
/// [WishlistDetailsScreen]
class WishlistDetailsRoute extends PageRouteInfo<void> {
  const WishlistDetailsRoute({List<PageRouteInfo>? children})
    : super(WishlistDetailsRoute.name, initialChildren: children);

  static const String name = 'WishlistDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WishlistDetailsScreen();
    },
  );
}
