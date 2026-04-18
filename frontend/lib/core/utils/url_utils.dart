import 'app_constants.dart';

// Utility class for handling URL formatting and transformations across the app.
class UrlUtils {
  // Converts a relative backend path to a full absolute URL.
  // If the path is already a full URL, it returns it unmodified.
  // Returns null if the path is null or empty.
  static String? getFullUrl(String? path) {
    if (path == null || path.isEmpty) return null;

    // If it's already a full web URL, return it as-is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Ensure we don't have double slashes when concatenating
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final cleanBaseUrl = AppConstants.baseUrl.endsWith('/')
        ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1)
        : AppConstants.baseUrl;

    // Combine the base URL from constants with the relative path
    return '$cleanBaseUrl/$cleanPath';
  }
}