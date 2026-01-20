import '../../../../core/common/typedef.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository _repository;

  CheckAuthStatusUseCase(this._repository);

  ResultFuture<bool> call() {
    return _repository.checkAuthStatus();
  }
}
