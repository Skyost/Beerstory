import 'dart:async';

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/widgets/circular_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Shows a waiting dialog.
Future<T> showWaitingOverlay<T>(
  BuildContext context, {
  FutureOr<T>? future,
  String? message,
}) async {
  OverlayEntry entry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        _ModalBarrier(),
        _WaitingDialog(
          message: message,
        ),
      ],
    ),
  );
  Overlay.of(context).insert(entry);
  if (future != null) {
    try {
      T result = await future;
      return result;
    } catch (ex) {
      rethrow;
    } finally {
      entry.remove();
    }
  }
  return null as T;
}

/// An animated modal barrier.
class _ModalBarrier extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ModalBarrierState();
}

/// The modal barrier state.
class _ModalBarrierState extends State<_ModalBarrier> with SingleTickerProviderStateMixin {
  /// The animation controller.
  late AnimationController controller = AnimationController(
    duration: context.theme.dialogRouteStyle.motion.entranceDuration,
    vsync: this,
  )..forward();

  @override
  Widget build(BuildContext context) => FAnimatedModalBarrier(
    onDismiss: null,
    filter: context.theme.dialogRouteStyle.barrierFilter,
    animation: controller.view,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// A waiting dialog, with or without a timeout.
class _WaitingDialog extends StatefulWidget {
  /// The message to display.
  final String? message;

  /// Creates a new waiting dialog instance.
  const _WaitingDialog({
    this.message,
  });

  @override
  State<StatefulWidget> createState() => _WaitingDialogState();
}

/// The waiting dialog state.
class _WaitingDialogState extends State<_WaitingDialog> {
  /// Whether we ran out of time.
  bool timedOut = false;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: FDialog(
      body: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 24),
            child: CenteredProgressIndicator(
              center: false,
            ),
          ),
          Expanded(
            child: Text(widget.message ?? translations.misc.loading),
          ),
        ],
      ),
      actions: [],
    ),
  );
}
