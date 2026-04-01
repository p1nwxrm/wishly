import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Service for secure data storage (e.g., JWT tokens)
class SecureStorageService {
  final FlutterSecureStorage _storage;

  // Keys for secure storage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Constructor initializes the storage instance
  SecureStorageService() : _storage = const FlutterSecureStorage();

  // Save the access token to secure storage
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  // Retrieve the access token from secure storage
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Save the refresh token to secure storage
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  // Retrieve the refresh token from secure storage
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Delete all data from storage (useful for logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}