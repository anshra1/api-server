import '../../../../core/common/typedef.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  ResultFuture<void> call() {
    return _repository.logout();
  }
}
