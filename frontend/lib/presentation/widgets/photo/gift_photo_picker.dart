import 'dart:io';
import 'package:flutter/material.dart';

// Reusable image picker widget specifically for rectangular items like gifts
class GiftPhotoPicker extends StatelessWidget {
  // The newly picked local image file
  final File? localImage;

  // URL of the existing image from the server (for editing later)
  final String? imageUrl;

  // Callback triggered when the picker is tapped
  final VoidCallback? onTap;

  // Disables interaction when true
  final bool isLoading;

  const GiftPhotoPicker({
    super.key,
    this.localImage,
    this.imageUrl,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: _buildContent(theme),
      ),
    );
  }

  // Helper method to determine what to display inside the container
  Widget _buildContent(ThemeData theme) {
    if (localImage != null) {
      // Prioritize the newly picked local image
      return ClipRRect(
        borderRadius: BorderRadius.circular(11), // Slightly less than container to fit inside border
        child: Image.file(localImage!, fit: BoxFit.cover, width: double.infinity),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Fallback to the existing network image
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.network(imageUrl!, fit: BoxFit.cover, width: double.infinity),
      );
    } else {
      // Fallback UI if no image is provided
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, color: theme.colorScheme.primary, size: 32),
          const SizedBox(height: 8),
          Text('Upload Photo', style: theme.textTheme.bodyMedium),
        ],
      );
    }
  }
}