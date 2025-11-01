import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// A simple centered circular progress indicator.
class CenteredProgressIndicator extends StatelessWidget {
  /// The duration.
  final Duration? duration;

  /// The value.
  final double? value;

  /// The size.
  final double? size;

  /// Whether the progress indicator should be centered.
  final bool center;

  /// Creates a new centered circular progress indicator instance.
  const CenteredProgressIndicator({
    super.key,
    this.duration,
    this.value,
    this.size,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = value == null
        ? FCircularProgress(
            style: (style) => style.copyWith(
              iconStyle: style.iconStyle.copyWith(
                color: MediaQuery.platformBrightnessOf(context) == Brightness.dark ? Colors.white : null,
                size: size,
              ),
            ),
          )
        : FDeterminateProgress(
            value: value!,
          );
    return center
        ? Center(
            child: child,
          )
        : child;
  }
}
