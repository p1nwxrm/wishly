import 'dart:io';

import 'package:flutter/material.dart';

import 'user_avatar.dart';

// Reusable photo picker widget handling both local files and existing user avatars
class AvatarPicker extends StatelessWidget {
  // The newly picked local image file
  final File? localImage;

  // URL of the existing profile image from the server
  final String? imageUrl;

  // Callback triggered when the avatar is tapped
  final VoidCallback? onTap;

  // Disables interaction when true
  final bool isLoading;

  // Controls the size of the photo
  final double radius;

  const AvatarPicker({
    super.key,
    this.localImage,
    this.imageUrl,
    this.onTap,
    this.isLoading = false,
    this.radius = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          localImage != null
              ? CircleAvatar(
            radius: radius,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            backgroundImage: FileImage(localImage!),
          )
              : UserAvatar(
            radius: radius,
            photoUrl: imageUrl,
          ),

          // Small camera icon badge
          Container(
            padding: EdgeInsets.all(radius * 0.15),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              Icons.camera_alt,
              size: radius * 0.33,
              color: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}