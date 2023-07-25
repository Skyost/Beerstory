import 'package:flutter/material.dart';

/// A tag widget.
class TagWidget extends StatelessWidget {
  /// The tag text.
  final String text;

  /// The right widget.
  final Widget? right;

  /// Creates a new tag widget instance.
  const TagWidget({
    super.key,
    required this.text,
    this.right,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.primary,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
            if (right != null) right!
          ],
        ),
      );
}
