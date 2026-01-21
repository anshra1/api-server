import '../../../../core/common/typedef.dart';
import '../repositories/auth_repository.dart';

/// Use case for user registration
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  /// Execute registration with email, password, and name
  ResultFuture<void> call({
    required String email,
    required String password,
    required String name,
  }) {
    return _repository.register(email, password, name);
  }
}
