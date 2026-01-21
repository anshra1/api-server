import '../../../../core/common/typedef.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class UpdateProfileUseCase {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  ResultFuture<User> call({String? name, String? picture}) {
    return repository.updateProfile(name: name, picture: picture);
  }
}
