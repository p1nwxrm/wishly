import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

// Import the generated router to get access to SignInRoute and SignUpCredentialsRoute
import '../../../core/router/app_router.dart';

@RoutePage()
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic material design visual layout structure
    return Scaffold(
      // SafeArea ensures UI is not obstructed by notches or system bars
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo Placeholder using the primary color from our theme
                Icon(
                  Icons.card_giftcard,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 32),

                // Greeting Title - automatically uses headlineMedium from AppTheme
                Text(
                  'Welcome to Wishly!',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // App Description - automatically uses bodyLarge from AppTheme
                Text(
                  'Create, share, and book gifts with your friends.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),

                // Sign In Button - automatically styled by elevatedButtonTheme
                ElevatedButton(
                  onPressed: () {
                    // Push the Sign In screen onto the navigation stack
                    context.router.push(const SignInRoute());
                  },
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 16),

                // Sign Up Button - automatically styled by outlinedButtonTheme
                OutlinedButton(
                  onPressed: () {
                    // Push the first step of the Sign Up flow onto the stack
                    context.router.push(const SignUpCredentialsRoute());
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}