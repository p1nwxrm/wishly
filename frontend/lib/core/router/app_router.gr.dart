// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [ConnectionsScreen]
class ConnectionsRoute extends PageRouteInfo<ConnectionsRouteArgs> {
  ConnectionsRoute({
    Key? key,
    required String username,
    int initialTab = 0,
    List<PageRouteInfo>? children,
  }) : super(
         ConnectionsRoute.name,
         args: ConnectionsRouteArgs(
           key: key,
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
      return WrappedRoute(
        child: ConnectionsScreen(
          key: args.key,
          username: args.username,
          initialTab: args.initialTab,
        ),
      );
    },
  );
}

class ConnectionsRouteArgs {
  const ConnectionsRouteArgs({
    this.key,
    required this.username,
    this.initialTab = 0,
  });

  final Key? key;

  final String username;

  final int initialTab;

  @override
  String toString() {
    return 'ConnectionsRouteArgs{key: $key, username: $username, initialTab: $initialTab}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ConnectionsRouteArgs) return false;
    return key == other.key &&
        username == other.username &&
        initialTab == other.initialTab;
  }

  @override
  int get hashCode => key.hashCode ^ username.hashCode ^ initialTab.hashCode;
}

/// generated route for
/// [EditProfileScreen]
class EditProfileRoute extends PageRouteInfo<EditProfileRouteArgs> {
  EditProfileRoute({
    Key? key,
    required UserBaseModel user,
    List<PageRouteInfo>? children,
  }) : super(
         EditProfileRoute.name,
         args: EditProfileRouteArgs(key: key, user: user),
         initialChildren: children,
       );

  static const String name = 'EditProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileRouteArgs>();
      return EditProfileScreen(key: args.key, user: args.user);
    },
  );
}

class EditProfileRouteArgs {
  const EditProfileRouteArgs({this.key, required this.user});

  final Key? key;

  final UserBaseModel user;

  @override
  String toString() {
    return 'EditProfileRouteArgs{key: $key, user: $user}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditProfileRouteArgs) return false;
    return key == other.key && user == other.user;
  }

  @override
  int get hashCode => key.hashCode ^ user.hashCode;
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
      return WrappedRoute(child: const MyProfileScreen());
    },
  );
}

/// generated route for
/// [PublicProfileScreen]
class PublicProfileRoute extends PageRouteInfo<PublicProfileRouteArgs> {
  PublicProfileRoute({
    Key? key,
    required String username,
    List<PageRouteInfo>? children,
  }) : super(
         PublicProfileRoute.name,
         args: PublicProfileRouteArgs(key: key, username: username),
         rawPathParams: {'username': username},
         initialChildren: children,
       );

  static const String name = 'PublicProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PublicProfileRouteArgs>(
        orElse: () =>
            PublicProfileRouteArgs(username: pathParams.getString('username')),
      );
      return WrappedRoute(
        child: PublicProfileScreen(key: args.key, username: args.username),
      );
    },
  );
}

class PublicProfileRouteArgs {
  const PublicProfileRouteArgs({this.key, required this.username});

  final Key? key;

  final String username;

  @override
  String toString() {
    return 'PublicProfileRouteArgs{key: $key, username: $username}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PublicProfileRouteArgs) return false;
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
      return WrappedRoute(child: const SearchScreen());
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
class WishlistDetailsRoute extends PageRouteInfo<WishlistDetailsRouteArgs> {
  WishlistDetailsRoute({
    Key? key,
    required int wishlistId,
    List<PageRouteInfo>? children,
  }) : super(
         WishlistDetailsRoute.name,
         args: WishlistDetailsRouteArgs(key: key, wishlistId: wishlistId),
         rawPathParams: {'id': wishlistId},
         initialChildren: children,
       );

  static const String name = 'WishlistDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<WishlistDetailsRouteArgs>(
        orElse: () =>
            WishlistDetailsRouteArgs(wishlistId: pathParams.getInt('id')),
      );
      return WrappedRoute(
        child: WishlistDetailsScreen(
          key: args.key,
          wishlistId: args.wishlistId,
        ),
      );
    },
  );
}

class WishlistDetailsRouteArgs {
  const WishlistDetailsRouteArgs({this.key, required this.wishlistId});

  final Key? key;

  final int wishlistId;

  @override
  String toString() {
    return 'WishlistDetailsRouteArgs{key: $key, wishlistId: $wishlistId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WishlistDetailsRouteArgs) return false;
    return key == other.key && wishlistId == other.wishlistId;
  }

  @override
  int get hashCode => key.hashCode ^ wishlistId.hashCode;
}
