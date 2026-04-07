import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class SignUpProfileScreen extends StatelessWidget {
  const SignUpProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SignUpProfileScreen')),
      body: const Center(child: Text('Sign Up Profile')),
    );
  }
}