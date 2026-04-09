import 'package:flutter/material.dart';

// A standardized loading indicator designed specifically to fit inside buttons
class ButtonLoadingIndicator extends StatelessWidget {
  // Optional color parameter if we need to override the default white color
  final Color? color;

  const ButtonLoadingIndicator({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color ?? Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}