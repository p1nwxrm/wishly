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
class ConnectionsRoute extends PageRouteInfo<ConnectionsRouteArgs> {
  ConnectionsRoute({
    Key? key,
    required int userId,
    required String username,
    int initialTab = 0,
    List<PageRouteInfo>? children,
  }) : super(
         ConnectionsRoute.name,
         args: ConnectionsRouteArgs(
           key: key,
           userId: userId,
           username: username,
           initialTab: initialTab,
         ),
         initialChildren: children,
       );

  static const String name = 'ConnectionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ConnectionsRouteArgs>();
      return ConnectionsScreen(
        key: args.key,
        userId: args.userId,
        username: args.username,
        initialTab: args.initialTab,
      );
    },
  );
}

class ConnectionsRouteArgs {
  const ConnectionsRouteArgs({
    this.key,
    required this.userId,
    required this.username,
    this.initialTab = 0,
  });

  final Key? key;

  final int userId;

  final String username;

  final int initialTab;

  @override
  String toString() {
    return 'ConnectionsRouteArgs{key: $key, userId: $userId, username: $username, initialTab: $initialTab}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ConnectionsRouteArgs) return false;
    return key == other.key &&
        userId == other.userId &&
        username == other.username &&
        initialTab == other.initialTab;
  }

  @override
  int get hashCode =>
      key.hashCode ^ userId.hashCode ^ username.hashCode ^ initialTab.hashCode;
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
class OtherUserProfileRoute extends PageRouteInfo<OtherUserProfileRouteArgs> {
  OtherUserProfileRoute({
    Key? key,
    required String username,
    List<PageRouteInfo>? children,
  }) : super(
         OtherUserProfileRoute.name,
         args: OtherUserProfileRouteArgs(key: key, username: username),
         rawPathParams: {'username': username},
         initialChildren: children,
       );

  static const String name = 'OtherUserProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<OtherUserProfileRouteArgs>(
        orElse: () => OtherUserProfileRouteArgs(
          username: pathParams.getString('username'),
        ),
      );
      return OtherUserProfileScreen(key: args.key, username: args.username);
    },
  );
}

class OtherUserProfileRouteArgs {
  const OtherUserProfileRouteArgs({this.key, required this.username});

  final Key? key;

  final String username;

  @override
  String toString() {
    return 'OtherUserProfileRouteArgs{key: $key, username: $username}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OtherUserProfileRouteArgs) return false;
    return key == other.key && username == other.username;
  }

  @override
  int get hashCode => key.hashCode ^ username.hashCode;
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
