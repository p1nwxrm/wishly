import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class SignUpCredentialsScreen extends StatelessWidget {
  const SignUpCredentialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SignUpCredentialsScreen')),
      body: const Center(child: Text('Sign Up Credentials')),
    );
  }
}