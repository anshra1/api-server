import '../../../../core/common/typedef.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  ResultFuture<void> call({required String username, required String password}) {
    return _repository.login(username, password);
  }
}
