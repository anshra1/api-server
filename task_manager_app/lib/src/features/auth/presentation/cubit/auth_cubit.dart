import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/auth_event_bus.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final LogoutUseCase _logoutUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final AuthEventBus _authEventBus;
  StreamSubscription? _authEventSubscription;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required LogoutUseCase logoutUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required AuthEventBus authEventBus,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _logoutUseCase = logoutUseCase,
        _changePasswordUseCase = changePasswordUseCase,
        _authEventBus = authEventBus,
        super(AuthInitial()) {
    _authEventSubscription = _authEventBus.onEvent.listen(
      (event) {
        if (event == AuthEvent.logout) {
          logout();
        }
      },
      onError: (error, stackTrace) {
        print('❌ AuthEventBus Error: $error');
      },
    );
  }

  @override
  Future<void> close() {
    _authEventSubscription?.cancel();
    return super.close();
  }

  /// Check if user is authenticated on app start
  Future<void> checkAuthStatus() async {
    final result = await _checkAuthStatusUseCase();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (isLoggedIn) => emit(isLoggedIn ? AuthAuthenticated() : AuthUnauthenticated()),
    );
  }

  /// Register a new user
  Future<void> register(String email, String password, String name) async {
    emit(AuthLoading());
    final result = await _registerUseCase(
      email: email,
      password: password,
      name: name,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthAuthenticated()),
    );
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await _loginUseCase(email: email, password: password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthAuthenticated()),
    );
  }

  /// Logout the current user
  Future<void> logout() async {
    emit(AuthLoading());
    await _logoutUseCase();
    emit(AuthUnauthenticated());
  }

  /// Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    emit(AuthLoading());
    final result = await _changePasswordUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthPasswordChanged()),
    );
  }
}
