import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SearchScreen')),
      body: const Center(child: Text('Search')),
    );
  }
}