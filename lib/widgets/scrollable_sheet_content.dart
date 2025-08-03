import 'package:beerstory/spacing.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// A scrollable sheet content widget.
class ScrollableSheetContentWidget extends StatelessWidget {
  /// The child builder.
  final Widget Function(BuildContext, ScrollController) builder;

  /// Creates a new scrollable sheet content widget instance.
  const ScrollableSheetContentWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    expand: false,
    builder: (context, controller) => ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.theme.colors.background,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: context.theme.colors.border,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: kSpace,
            horizontal: kSpace * 2,
          ),
          child: builder(context, controller),
        ),
      ),
    ),
  );
}
