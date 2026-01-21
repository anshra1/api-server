import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/auth_event_bus.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthEventBus _authEventBus;
  StreamSubscription? _authEventSubscription;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthEventBus authEventBus,
  })  : _loginUseCase = loginUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _logoutUseCase = logoutUseCase,
        _authEventBus = authEventBus,
        super(AuthInitial()) {
    _authEventSubscription = _authEventBus.onEvent.listen(
      (event) {
        if (event == AuthEvent.logout) {
          logout();
        }
      },
      onError: (error, stackTrace) {
        // Log the error but don't crash
        print('❌ AuthEventBus Error: $error');
        // Optionally: log to Crashlytics/Sentry
      },
    );
  }

  @override
  Future<void> close() {
    _authEventSubscription?.cancel();
    return super.close();
  }

  Future<void> checkAuthStatus() async {
    final result = await _checkAuthStatusUseCase();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (isLoggedIn) => emit(isLoggedIn ? AuthAuthenticated() : AuthUnauthenticated()),
    );
  }

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    final result = await _loginUseCase(username: username, password: password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthAuthenticated()),
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await _logoutUseCase();
    emit(AuthUnauthenticated());
  }
}
