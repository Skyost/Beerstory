import 'package:beerstory/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:forui/assets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// The scanner error widget.
class ScannerErrorWidget extends StatelessWidget {
  /// The error.
  final MobileScannerException error;

  /// Creates a new scanner error widget instance.
  const ScannerErrorWidget({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.black,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Icon(
              FIcons.circleAlert,
              color: Colors.white,
            ),
          ),
          Text(
            switch (error.errorCode) {
              MobileScannerErrorCode.controllerUninitialized => translations.error.scan.controllerUninitialized,
              MobileScannerErrorCode.permissionDenied => translations.error.scan.permissionDenied,
              MobileScannerErrorCode.unsupported => translations.error.scan.unsupported,
              _ => translations.error.scan.genericError,
            },
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            error.errorDetails?.message ?? '',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
  );
}
