import 'package:flutter/material.dart';

/// A simple large styled button.
class LargeButton extends StatelessWidget {
  /// The button padding.
  final EdgeInsets? padding;

  /// The text.
  final String text;

  /// Callback for when the button has been pressed.
  final VoidCallback onPressed;

  /// Creates a new app button instance.
  const LargeButton({
    super.key,
    this.padding,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    width: MediaQuery.of(context).size.width,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        text.toUpperCase(),
      ),
    ),
  );
}
