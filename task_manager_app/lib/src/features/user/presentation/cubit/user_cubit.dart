import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  UserCubit({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
        super(UserInitial());

  Future<void> loadProfile() async {
    emit(UserLoading());
    final result = await _getProfileUseCase();
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserLoaded(user)),
    );
  }

  Future<void> updateProfile({String? name, String? picture}) async {
    emit(UserLoading());
    final result = await _updateProfileUseCase(name: name, picture: picture);
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserLoaded(user)),
    );
  }

  Future<void> deleteAccount(String password) async {
    emit(UserLoading());
    final result = await _deleteAccountUseCase(password);
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (_) => emit(const UserActionSuccess("Account deleted successfully")),
    );
  }
}
