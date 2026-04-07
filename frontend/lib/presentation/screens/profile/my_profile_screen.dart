import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MyProfileScreen')),
      body: const Center(child: Text('My Profile')),
    );
  }
}