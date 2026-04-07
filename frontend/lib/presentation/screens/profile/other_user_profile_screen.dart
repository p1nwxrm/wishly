import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class OtherUserProfileScreen extends StatelessWidget {
  const OtherUserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OtherUserProfileScreen')),
      body: const Center(child: Text('Other User Profile')),
    );
  }
}