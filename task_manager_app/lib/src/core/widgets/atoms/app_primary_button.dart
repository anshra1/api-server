import 'package:flutter/material.dart';

enum AppButtonSize { small, medium, large }
enum AppButtonState { enabled, disabled, loading }

class AppPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonState state;
  final AppButtonSize size;

  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.state = AppButtonState.enabled,
    this.size = AppButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = state != AppButtonState.enabled;
    
    return FilledButton(
      onPressed: isDisabled ? null : onPressed,
      style: FilledButton.styleFrom(
        // Add specific styling based on size here
      ),
      child: state == AppButtonState.loading
          ? const SizedBox(
              width: 16, 
              height: 16, 
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : child,
    );
  }
}
