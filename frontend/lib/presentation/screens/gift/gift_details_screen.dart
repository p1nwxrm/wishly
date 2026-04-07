import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class GiftDetailsScreen extends StatelessWidget {
  const GiftDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GiftDetailsScreen')),
      body: const Center(child: Text('Gift Details')),
    );
  }
}