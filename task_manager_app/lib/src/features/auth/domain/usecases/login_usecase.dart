import '../../../../core/common/typedef.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Execute login with email and password
  ResultFuture<void> call({required String email, required String password}) {
    return _repository.login(email, password);
  }
}
