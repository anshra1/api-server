import '../../../../core/common/typedef.dart';
import '../entities/user.dart';

abstract class UserRepository {
  /// Get current user profile
  ResultFuture<User> getProfile();

  /// Update user profile
  ResultFuture<User> updateProfile({
    String? name,
    String? picture,
  });

  /// Delete user account
  ResultFuture<void> deleteAccount(String password);

  /// Get account statistics (returns Map for simplicity or dedicated object)
  ResultFuture<Map<String, dynamic>> getAccountStats();
}
