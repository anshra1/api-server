import 'dart:async';

enum AuthEvent { logout }

/// AuthEventBus - A simple event bus for authentication events.
///
/// Used to decouple the network layer (Interceptors) from the UI layer (Cubits).
/// When an interceptor detects a critical auth failure, it broadcasts a logout event.
class AuthEventBus {
  final _controller = StreamController<AuthEvent>.broadcast();

  /// Stream of auth events. Listeners should handle errors gracefully.
  Stream<AuthEvent> get onEvent => _controller.stream;

  /// Returns true if the bus has been disposed.
  bool get isClosed => _controller.isClosed;

  /// Broadcasts a logout event to all listeners.
  /// Safe to call even if no listeners are attached.
  void logout() {
    if (!_controller.isClosed) {
      _controller.add(AuthEvent.logout);
    }
  }

  /// Broadcasts an error to all listeners (if needed for debugging/logging).
  void addError(Object error, [StackTrace? stackTrace]) {
    if (!_controller.isClosed) {
      _controller.addError(error, stackTrace);
    }
  }

  /// Closes the stream. Call this when the app is disposing.
  void dispose() {
    _controller.close();
  }
}
