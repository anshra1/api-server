/// API Endpoints
///
/// All API endpoint paths used by the app.
/// Base URL is configured in [DioProvider].
class ApiEndpoints {
  ApiEndpoints._();

  // ==================
  // Base URLs
  // ==================
  static const String baseUrlAndroid = 'http://10.0.2.2:3000';
  static const String baseUrlLocal = 'http://127.0.0.1:3000';

  // ==================
  // Auth Endpoints
  // ==================
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-password';

  // ==================
  // User Endpoints
  // ==================
  static const String userProfile = '/users/me';
  static const String userStats = '/users/me/stats';

  // ==================
  // Task Endpoints
  // ==================
  static const String tasks = '/tasks';
  static const String taskStats = '/tasks/stats';
  static const String taskCategories = '/tasks/categories';
  static const String taskBatchComplete = '/tasks/batch/complete';
  static const String taskBatchDelete = '/tasks/batch';
  static const String taskByIdPattern = '/tasks/{id}';

  /// Returns task endpoint with ID, e.g., `/tasks/abc-123`
  static String taskById(String id) => '/tasks/$id';

  // ==================
  // API Keys (Backend-Specific)
  // ==================
  // These keys vary by backend. Change them when switching servers.

  /// Key used in refresh token request body
  static const String refreshTokenRequestKey = 'refreshToken';

  /// Key used in refresh token response for new access token
  static const String accessTokenResponseKey = 'accessToken';
}
