import 'package:flutter/material.dart';

/// A simple history button.
class HistoryButton extends StatelessWidget {
  /// Creates a new history button instance.
  const HistoryButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.history),
        onPressed: () => Navigator.pushNamed(context, '/history'),
      );
}
