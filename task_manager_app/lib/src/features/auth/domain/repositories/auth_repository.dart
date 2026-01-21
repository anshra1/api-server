import '../../../../core/common/typedef.dart';

/// Abstract interface for auth repository
abstract class AuthRepository {
  /// Register a new user with email, password, and name
  ResultFuture<void> register(String email, String password, String name);

  /// Login with email and password
  ResultFuture<void> login(String email, String password);

  /// Check if user is currently authenticated
  ResultFuture<bool> checkAuthStatus();

  /// Logout and clear tokens
  ResultFuture<void> logout();

  /// Change password
  ResultFuture<void> changePassword(String currentPassword, String newPassword);
}
