import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'presentation/blocs/blocs.dart';
import 'core/theme/app_theme.dart';

void main() {
  // Catch all errors in the global zone
  runZonedGuarded(
        () => _bootstrap(),
        (error, stack) {
      // Even if setupDependencies fails, we will catch it here
      getIt<Talker>().handle(error, stack);
    },
  );
}

// Extracted initialization logic to reduce nesting in main()
Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  final talker = getIt<Talker>();

  // Set Talker as the global BLoC observer
  Bloc.observer = TalkerBlocObserver(
    talker: talker,
    settings: const TalkerBlocLoggerSettings(
      // Print everything related to BLoC transitions
      printEventFullData: false,
      printStateFullData: false,
      printChanges: false,
      printClosings: true,
      printCreations: true,
      printEvents: true,
      printTransitions: true,
    ),
  );

  FlutterError.onError = (details) {
    talker.handle(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack);
    return true;
  };

  talker.info('Wishly App initialized successfully');

  runApp(const WishlyApp());
}

class WishlyApp extends StatelessWidget {
  const WishlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return MultiBlocProvider(
      providers: [
        // Providing all BLoCs globally at the top level of the widget tree
        BlocProvider<AuthBloc>(create: (context) => getIt<AuthBloc>()),
        BlocProvider<UserBloc>(create: (context) => getIt<UserBloc>()),
        BlocProvider<WishlistBloc>(create: (context) => getIt<WishlistBloc>()),
        BlocProvider<GiftBloc>(create: (context) => getIt<GiftBloc>()),
        BlocProvider<BookingBloc>(create: (context) => getIt<BookingBloc>()),
        BlocProvider<SubscriptionBloc>(create: (context) => getIt<SubscriptionBloc>()),
        BlocProvider<TagBloc>(create: (context) => getIt<TagBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Wishlist App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Delegate routing logic to auto_route
        routerConfig: appRouter.config(
          // Track navigation events using TalkerRouteObserver - logs all route changes
          navigatorObservers: () => [
            TalkerRouteObserver(getIt<Talker>())
          ]
        ),
      ),
    );
  }
}
