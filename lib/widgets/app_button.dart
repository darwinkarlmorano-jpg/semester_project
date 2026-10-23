import 'package:flutter/material.dart';

/// Shared button. Used in HomeScreen AND ReportFormScreen (reuse evidence).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // null = disabled
  final bool isLoading;
  final IconData? icon;
  final bool outlined;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    final effective = isLoading ? null : onPressed; // blocks duplicate taps

    return SizedBox(
      height: 48,
      child: outlined
          ? OutlinedButton(onPressed: effective, child: child)
          : ElevatedButton(onPressed: effective, child: child),
    );
  }
}