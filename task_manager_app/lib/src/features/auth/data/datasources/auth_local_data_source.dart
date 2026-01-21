import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  AuthLocalDataSource(this._storage);

  static const _accessTokenKey = 'ACCESS_TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      print('💾 Saving tokens to secure storage...');
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      print('✅ Tokens saved successfully.');
    } catch (e) {
      print('❌ Failed to save tokens: $e');
      rethrow;
    }
  }

  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token == null) {
        print('⚠️ Access token not found in storage.');
      } else {
        // print('🔐 Access token retrieved (length: ${token.length})');
      }
      return token;
    } catch (e) {
      print('❌ Failed to read access token: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
