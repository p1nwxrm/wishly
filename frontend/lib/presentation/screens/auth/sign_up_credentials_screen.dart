import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/common/custom_app_bar.dart';

@RoutePage()
class SignUpCredentialsScreen extends StatefulWidget {
  const SignUpCredentialsScreen({super.key});

  @override
  State<SignUpCredentialsScreen> createState() => _SignUpCredentialsScreenState();
}

class _SignUpCredentialsScreenState extends State<SignUpCredentialsScreen> {
  // Form key for triggering validation on inputs
  final _formKey = GlobalKey<FormState>();

  // Controllers to read text from input fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Handle the Next button press
  void _onNextPressed() {
    // Validate all fields (including password match)
    if (_formKey.currentState?.validate() ?? false) {
      context.router.push(
        SignUpProfileRoute(
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
        title: 'Sign Up - Step 1',
      ),
      body: SafeArea(
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
                    'Create an Account',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email input field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
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
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Create a password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      // \x21-\x7E covers all visible characters of the English keyboard without spaces
                      final passwordRegex = RegExp(r'^[\x21-\x7E]+$');
                      if (!passwordRegex.hasMatch(value)) {
                        return 'Use only Latin letters, numbers, and special characters';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password input field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Repeat your password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Next step button
                  ElevatedButton(
                    onPressed: _onNextPressed,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}