import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Allows to blur a widget. Kudos to "jagritjkh/blur" for the initial implementation.
class BlurWidget extends ConsumerStatefulWidget {
  /// Value of blur effect, higher the blur more the blur effect.
  final double blur;

  /// Radius of the child to be blurred.
  final BorderRadius? borderRadius;

  /// Opacity of the blurColor.
  final double colorOpacity;

  /// Widget that can be stacked over blurred widget.
  final Widget? child;

  /// Alignment geometry of the overlay.
  final AlignmentGeometry alignment;

  /// Creates a new blur widget instance.
  const BlurWidget({
    super.key,
    this.blur = 5,
    this.borderRadius,
    this.colorOpacity = 0.5,
    this.child,
    this.alignment = Alignment.center,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BlurWidgetState();
}

/// The blur widget state.
class _BlurWidgetState extends ConsumerState<BlurWidget> {
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: widget.borderRadius ?? BorderRadius.zero,
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
      child: Container(
        decoration: BoxDecoration(
          color: (MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.black : Colors.white).withValues(alpha: widget.colorOpacity),
        ),
        alignment: widget.alignment,
        child: widget.child,
      ),
    ),
  );
}
