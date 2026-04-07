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
                // App Logo Placeholder (using a built-in icon for now)
                const Icon(
                  Icons.card_giftcard,
                  size: 100,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 32),

                // Greeting Title
                Text(
                  'Welcome to Wishly!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // App Description
                Text(
                  'Create, share, and book gifts easily with your friends.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),

                // Sign In Button
                ElevatedButton(
                  onPressed: () {
                    // Push the Sign In screen onto the navigation stack
                    context.router.push(const SignInRoute());
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign Up Button
                OutlinedButton(
                  onPressed: () {
                    // Push the first step of the Sign Up flow onto the stack
                    context.router.push(const SignUpCredentialsRoute());
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

