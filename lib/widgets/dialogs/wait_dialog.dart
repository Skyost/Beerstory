import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:flutter/material.dart';

/// A dialog that allows to tell the user to wait.
class WaitDialog extends StatelessWidget {
  /// Creates a new wait dialog instance.
  const WaitDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) => const AlertDialog(
        content: CenteredCircularProgressIndicator(),
      );

  /// Shows the dialog.
  static void show({
    required BuildContext context,
  }) =>
      showDialog(
        context: context,
        builder: (context) => const WaitDialog(),
        barrierDismissible: false,
      );
}
