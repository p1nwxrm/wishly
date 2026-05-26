import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/url_utils.dart';

// A highly reusable wrapper around CachedNetworkImage.
// It handles URL formatting, loading states, and error fallbacks,
// without enforcing any specific shape, size, or container.
class AppCachedNetworkImage extends StatelessWidget {
  // The raw image URL from the backend.
  final String? imageUrl;

  // The widget to display if the URL is null, invalid, or fails to load.
  final Widget fallbackWidget;

  // How the image should be inscribed into the available space.
  final BoxFit fit;

  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    required this.fallbackWidget,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Process the URL to ensure it's absolute and valid.
    final fullUrl = UrlUtils.getFullUrl(imageUrl);
    final hasPhoto = fullUrl != null;

    // If there is no valid URL, immediately return the fallback widget.
    if (!hasPhoto) {
      return fallbackWidget;
    }

    // Return the actual network image with built-in state handling.
    return CachedNetworkImage(
      imageUrl: fullUrl,
      fit: fit,
      // Display a centered, subtle loading indicator while downloading.
      placeholder: (context, url) => Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
      // Crucial: If the server returns 404 or the download fails, show the fallback.
      errorWidget: (context, url, error) => fallbackWidget,
    );
  }
}