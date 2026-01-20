import 'dart:async';

enum AuthEvent { logout }

class AuthEventBus {
  final _controller = StreamController<AuthEvent>.broadcast();

  Stream<AuthEvent> get onEvent => _controller.stream;

  void logout() => _controller.add(AuthEvent.logout);

  void dispose() {
    _controller.close();
  }
}

