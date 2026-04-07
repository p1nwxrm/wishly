import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class WishlistDetailsScreen extends StatelessWidget {
  const WishlistDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WishlistDetailsScreen')),
      body: const Center(child: Text('Wishlist Details')),
    );
  }
}