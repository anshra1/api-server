import '../../../../core/common/typedef.dart';
import '../repositories/user_repository.dart';

class DeleteAccountUseCase {
  final UserRepository repository;

  DeleteAccountUseCase(this.repository);

  ResultFuture<void> call(String password) {
    return repository.deleteAccount(password);
  }
}
