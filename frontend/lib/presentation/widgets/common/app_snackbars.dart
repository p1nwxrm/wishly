import 'package:flutter/material.dart';

// Utility class for displaying standardized notifications across the app
class AppSnackbars {
  // Displays an error message using the default snackbar theme (red)
  static void showError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
    // Removes the current snackbar instantly if the user spams the button
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.error,
          content: Row(
            children: [
              Icon(Icons.error_outline, color: colorScheme.onError),
              const SizedBox(width: 12),
              // Expanded prevents text overflow if the error message is too long
              Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: colorScheme.onError),
                  )
              ),
            ],
          ),
        ),
      );
  }

  // Displays a success message using a hardcoded green
  static void showSuccess(BuildContext context, String message) {
    // For success, Material 3 doesn't have a default 'success' color slot.
    // We can use a custom green here
    const successColor = Color(0xFF4CAF50);
    const onSuccessColor = Colors.white;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: successColor,
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: onSuccessColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: onSuccessColor),
                ),
              ),
            ],
          ),
        ),
      );
  }
}