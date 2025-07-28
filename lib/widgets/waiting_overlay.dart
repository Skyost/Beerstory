import 'package:beerstory/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Shows a waiting dialog.
Future<T> showWaitingOverlay<T>(
  BuildContext context, {
  Future<T>? future,
  String? message,
  bool Function()? onCancel,
}) async {
  OverlayEntry entry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        const ModalBarrier(
          dismissible: false,
          color: Colors.black54,
        ),
        _WaitingDialog(
          message: message,
          onCancel: onCancel,
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

/// A waiting dialog, with or without a timeout.
class _WaitingDialog extends StatefulWidget {
  /// The message to display.
  final String? message;

  /// The cancel callback.
  final bool Function()? onCancel;

  /// Creates a new waiting dialog instance.
  const _WaitingDialog({
    this.message,
    this.onCancel,
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
        child: AlertDialog(
          scrollable: false,
          actions: widget.onCancel == null
              ? null
              : [
                  TextButton(
                    child: Text(translations.misc.cancel),
                    onPressed: () {
                      if (widget.onCancel!()) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
          content: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 24),
                child: FProgress.circularIcon(),
              ),
              Expanded(
                child: Text(widget.message ?? translations.misc.loading),
              ),
            ],
          ),
        ),
      );
}
