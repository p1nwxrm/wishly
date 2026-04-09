import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../../utils/app_snackbars.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/button_loading_indicator.dart';

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

  // Handle the login button press
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Sign In',
      ),
      // BlocConsumer handles both UI rebuilding and side effects like navigation
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Preload user data if the backend returned it during login
            if (state.user != null) {
              context.read<UserBloc>().add(PreloadUser(user: state.user!));
            }

            // Navigate to the main feed screen and remove login from stack
            context.router.replaceAll([const RootRoute()]);
          } else if (state is AuthFailure) {
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Please enter a valid email format';
                          }
                          return null;
                        },
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
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
                        onPressed: isLoading
                            ? null
                            : () {
                          // Navigate to the first step of the Sign Up flow
                          context.router.push(const SignUpCredentialsRoute());
                        },
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