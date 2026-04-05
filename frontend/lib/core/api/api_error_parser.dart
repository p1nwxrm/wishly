import 'package:dio/dio.dart';

// Utility class for parsing API errors across the entire app
class ApiErrorParser {
  // Static method allows us to call it without creating an instance of the class
  static String extractMessage(
      DioException e, {
        String defaultMsg = 'Network error occurred. Please try again.',
      }) {
    // Check if we received a response from the server
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;

      // Check if the response contains the 'detail' key (FastAPI standard)
      if (data is Map<String, dynamic> && data.containsKey('detail')) {
        return data['detail'].toString();
      } else {
        // Fallback for 500 Server Errors or unexpected HTML responses
        return 'Server error: ${e.response?.statusCode}';
      }
    }

    // Return the default message if there is no internet connection or a timeout
    return defaultMsg;
  }
}