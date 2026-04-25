import 'package:flutter/material.dart';
import '../../../core/utils/url_utils.dart';
import '../common/app_cached_network_image.dart';

// A reusable widget to display a user's photo across the app.
// It automatically handles the fallback state when the user doesn't have a photo.
class UserAvatar extends StatelessWidget {
  // Optional URL of the user's profile image from the server.
  final String? photoUrl;

  // Mandatory radius to control the size of the photo.
  final double radius;

  const UserAvatar({
    super.key,
    required this.radius,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Process the raw photoUrl through our global utility
    final fullImageUrl = UrlUtils.getFullUrl(photoUrl);
    final hasPhoto = fullImageUrl != null;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
      child: hasPhoto
          ? ClipOval(
        child: SizedBox.expand(
          child: AppCachedNetworkImage(
            imageUrl: photoUrl,
            fallbackWidget: Icon(
              Icons.person,
              size: radius * 1.2,
              color: colorScheme.primary,
            ),
          ),
        ),
      )
      // Default state when there is no URL provided at all
          : Icon(
        Icons.person,
        size: radius * 1.2,
        color: colorScheme.primary,
      ),
    );
  }
}