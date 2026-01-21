import '../../../../core/common/typedef.dart';
import '../repositories/auth_repository.dart';

/// Use case for changing password
class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  /// Execute password change
  ResultFuture<void> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(currentPassword, newPassword);
  }
}
