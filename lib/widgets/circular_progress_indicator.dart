import 'package:beerstory/utils/brightness_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// A simple centered circular progress indicator.
class CenteredProgressIndicator extends ConsumerStatefulWidget {
  /// Creates a new centered circular progress indicator instance.
  const CenteredProgressIndicator({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CenteredProgressIndicatorState();
}

/// The centered circular progress indicator state.
class _CenteredProgressIndicatorState extends ConsumerState<CenteredProgressIndicator> with BrightnessListener<CenteredProgressIndicator> {
  @override
  Widget build(BuildContext context) => Center(
    child: FCircularProgress(
      style: (style) => style.copyWith(
        iconStyle: style.iconStyle.copyWith(
          color: MediaQuery.platformBrightnessOf(context) == Brightness.dark ? Colors.white : null,
        ),
      ),
    ),
  );
}
