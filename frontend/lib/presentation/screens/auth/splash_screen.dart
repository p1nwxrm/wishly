import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import the generated router
import '../../../core/router/app_router.dart';
// Import BLoCs via the barrel file
import '../../blocs/blocs.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch the event to check tokens and verify session when the screen initializes
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    // BlocListener reacts to state changes without rebuilding the UI
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Navigate based on the strict authentication state
        if (state is AuthSuccess) {
          if (state.user != null) {
            context.read<UserBloc>().add(PreloadUser(user: state.user!));
          }

          // Session is valid, replace splash with the main layout
          context.router.replace(const RootRoute());
        } else if (state is AuthUnauthenticated || state is AuthFailure) {
          // No valid session, redirect to the welcome screen
          context.router.replace(const WelcomeRoute());
        }
      },
      child: const Scaffold(
        body: Center(
          // Show a loading indicator while the strict network check is in progress
          child: CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }
}