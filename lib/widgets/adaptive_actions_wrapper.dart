import 'package:beerstory/spacing.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Allows to adapt the [actions] list to the platform.
class AdaptiveActionsWrapper extends StatelessWidget {
  /// The actions.
  final List<FButton> actions;

  /// Creates a new adaptive actions wrapper instance.
  const AdaptiveActionsWrapper({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) => switch (MediaQuery.sizeOf(context).width) {
    final width when width < context.theme.breakpoints.sm =>
        Column(
          spacing: kSpace,
          children: actions,
        ),
    _ =>
        Wrap(
          spacing: kSpace / 2,
          runSpacing: kSpace,
          alignment: WrapAlignment.end,
          children: [
            for (Widget button in actions)
              IntrinsicWidth(
                child: button,
              ),
          ],
        ),
  };
}
