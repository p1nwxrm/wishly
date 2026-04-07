import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class AddGiftScreen extends StatelessWidget {
  const AddGiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AddGiftScreen')),
      body: const Center(child: Text('Add Gift')),
    );
  }
}