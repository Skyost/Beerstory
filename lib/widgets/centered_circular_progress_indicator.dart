import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// A simple centered circular progress indicator.
class CenteredCircularProgressIndicator extends StatelessWidget {
  /// Creates a new centered circular progress indicator instance.
  const CenteredCircularProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) => const Center(
    child: FProgress.circularIcon(),
  );
}
