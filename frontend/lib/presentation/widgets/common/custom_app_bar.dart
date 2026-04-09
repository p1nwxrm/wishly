import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

// Import GetIt to access our global Talker instance
import '../../../core/di/injection.dart';

// Reusable custom AppBar that automatically includes a debug logger button
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        // Include any screen-specific actions passed to the widget
        ...?actions,

        // Global debug button to open Talker UI
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TalkerScreen(
                  talker: getIt<Talker>(),
                ),
              ),
            );
          },
          icon: const Icon(Icons.document_scanner_outlined),
        ),
      ],
    );
  }

  // Required override for PreferredSizeWidget to set standard AppBar height
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}