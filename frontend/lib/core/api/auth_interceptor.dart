import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';
import '../utils/app_constants.dart';
import '../../data/models/token_models.dart';

// Interceptor for injecting JWT tokens and handling 401 Unauthorized errors
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService storage;

  // We inject SecureStorageService through the constructor
  AuthInterceptor(this.dio, this.storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 1. Skip token injection for endpoints that do not require it
    if (options.path.contains('/auth/login') ||
        options.path.contains('/users/register') ||
        options.path.contains('/auth/refresh')) {
      return handler.next(options);
    }

    // 2. Fetch the access token from local storage
    final accessToken = await storage.getAccessToken();

    // 3. Inject token into headers if it exists
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if the error is 401 Unauthorized (token expired or invalid)
    if (err.response?.statusCode == 401) {

      // Prevent infinite loops if the refresh endpoint itself returns 401
      if (err.requestOptions.path.contains('/auth/refresh')) {
        await storage.clearAll(); // Wipe bad tokens
        // TODO: Redirect user to LoginScreen via auto_route
        return handler.next(err);
      }

      try {
        // 1. Fetch refresh token from storage
        final refreshToken = await storage.getRefreshToken();

        // If there is no refresh token, we can't refresh. User must log in.
        if (refreshToken == null || refreshToken.isEmpty) {
          await storage.clearAll();
          // TODO: Redirect user to LoginScreen via auto_route
          return handler.next(err);
        }

        // Create our strongly-typed request model for the refresh payload
        final refreshRequest = TokenRefreshModel(refreshToken: refreshToken);

        // 2. Request a new token pair from FastAPI using our global constant
        // Note: We use a new Dio instance here to avoid triggering this same interceptor
        final refreshResponse = await Dio().post(
          '${AppConstants.baseUrl}/auth/refresh',
          // Dio automatically encodes our model to JSON via toJson()
          data: refreshRequest.toJson(),
        );

        // 3. Parse the response using our strongly-typed TokenModel
        final newTokens = TokenModel.fromJson(refreshResponse.data);

        // 4. Save the new tokens back to secure storage
        await storage.saveAccessToken(newTokens.accessToken);
        await storage.saveRefreshToken(newTokens.refreshToken);

        // 5. Update the authorization header of the original failed request
        err.requestOptions.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';

        // 6. Retry the original request with the new access token
        final retryResponse = await dio.fetch(err.requestOptions);

        // 7. Resolve the error with the successful retry response
        return handler.resolve(retryResponse);

      } on DioException catch (refreshErr) {
        // If refreshing fails (e.g., refresh token is expired or invalid)
        await storage.clearAll();
        // TODO: Redirect user to LoginScreen via auto_route
        return handler.next(refreshErr);
      }
    }

    // Pass all other errors normally
    return handler.next(err);
  }
}