import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SignInScreen')),
      body: const Center(child: Text('SignIn')),
    );
  }
}