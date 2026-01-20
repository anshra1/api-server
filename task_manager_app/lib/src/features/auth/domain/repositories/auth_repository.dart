import '../../../../core/common/typedef.dart';

abstract class AuthRepository {
  ResultFuture<void> login(String username, String password);
  ResultFuture<bool> checkAuthStatus();
  ResultFuture<void> logout();
}
