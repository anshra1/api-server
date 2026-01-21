/// API Endpoints
///
/// All API endpoint paths used by the app.
/// Base URL is configured in [DioProvider].
class ApiEndpoints {
  ApiEndpoints._();

  // ==================
  // Auth Endpoints
  // ==================
  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // ==================
  // Task Endpoints
  // ==================
  static const String tasks = '/tasks';

  /// Returns task endpoint with ID, e.g., `/tasks/abc-123`
  static String taskById(String id) => '/tasks/$id';
}
