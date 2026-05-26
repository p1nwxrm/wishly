import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/common/app_snackbars.dart';
import '../../widgets/common/common.dart';

@RoutePage()
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Form key for triggering validation on inputs
  final _formKey = GlobalKey<FormState>();

  // Controllers to read text from input fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Actions & Callbacks
  // --------------------------------------------------------------------------

  /// Handles the login button press
  void _onLoginPressed() {
    // Validate all fields before sending the request
    if (_formKey.currentState?.validate() ?? false) {
      // Dispatch LoginRequested event to AuthBloc
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  /// Handles navigation to the Sign Up flow
  void _onSignUpPressed() {
    context.router.push(const SignUpCredentialsRoute());
  }

  // --------------------------------------------------------------------------
  // Validators
  // --------------------------------------------------------------------------

  /// Validates the email input format
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email format';
    }

    return null; // Null means the input is valid
  }

  /// Validates the password input format
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    return null; // Null means the input is valid
  }

  // --------------------------------------------------------------------------
  // Build Method
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      // BlocConsumer handles both UI rebuilding and side effects like navigation
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            // Show error message via snackbar on failure
            AppSnackbars.showError(context, state.errorMessage);
          }
        },
        builder: (context, state) {
          // Check if request is in progress to disable inputs and show loader
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Email input field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // Password input field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        enabled: !isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 32),

                      // Login submit button
                      ElevatedButton(
                        // Disable button if currently loading
                        onPressed: isLoading ? null : _onLoginPressed,
                        child: isLoading
                            ? const ButtonLoadingIndicator()
                            : const Text('Log In'),
                      ),
                      const SizedBox(height: 16),

                      // Navigation to Sign Up screen
                      TextButton(
                        // Disable button if currently loading
                        onPressed: isLoading ? null : _onSignUpPressed,
                        child: const Text('Don\'t have an account? Sign Up'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}