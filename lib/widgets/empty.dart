import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Displayed when there is no element to show.
class EmptyWidget extends StatelessWidget {
  /// The text to display.
  final String text;

  /// Creates a new empty widget instance.
  const EmptyWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Icon(
          FIcons.circleSlash2,
          color: context.theme.colors.mutedForeground,
        ),
      ),
      Text(
        text,
        style: context.theme.typography.base.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
    ],
  );
}
