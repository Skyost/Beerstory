import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
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
                child: Icon(Icons.error, color: Colors.white),
              ),
              Text(
                switch (error.errorCode) {
                  MobileScannerErrorCode.controllerUninitialized => context.getString('error.scanControllerUninitialized'),
                  MobileScannerErrorCode.permissionDenied => context.getString('scanPermissionDenied'),
                  MobileScannerErrorCode.unsupported => context.getString('scanUnsupported'),
                  _ => context.getString('scanGenericError'),
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
