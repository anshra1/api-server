import '../../../../core/common/typedef.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetProfileUseCase {
  final UserRepository repository;

  GetProfileUseCase(this.repository);

  ResultFuture<User> call() {
    return repository.getProfile();
  }
}
