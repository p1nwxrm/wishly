import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../widgets/common/custom_app_bar.dart';

@RoutePage()
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'RootScreen',
      ),
      body: const Center(child: Text('Root')),
    );
  }
}