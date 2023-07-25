import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';

/// A simple form label widget with an icon and a text.
class LabelWidget extends StatelessWidget {
  /// The icon.
  final IconData icon;

  /// The text.
  final String textKey;

  /// Creates a new label instance.
  const LabelWidget({
    super.key,
    required this.icon,
    required this.textKey,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Flexible(
            child: Text(
              context.getString(textKey),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
}
