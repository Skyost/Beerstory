import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/blur.dart';
import 'package:beerstory/widgets/scan/scanner_button_widgets.dart';
import 'package:beerstory/widgets/scan/scanner_error_widget.dart';
import 'package:flutter/material.dart' hide CloseButton;
import 'package:mobile_scanner/mobile_scanner.dart';

/// A barcode scanner widget.
class BarcodeScanner extends StatefulWidget {
  /// Triggered when a barcode has been scanned.
  final Function(BarcodeCapture barcodes)? onScan;

  /// Triggered when an error occurred.
  final Function(Object error, StackTrace? stackTrace)? onScanError;

  /// Triggered when the close button has been pressed.
  final VoidCallback? onCloseButtonPress;

  /// Creates a new barcode scanner instance.
  const BarcodeScanner({
    super.key,
    this.onScan,
    this.onScanError,
    this.onCloseButtonPress,
  });

  @override
  State<StatefulWidget> createState() => _BarcodeScannerState();
}

/// The barcode scanner state.
class _BarcodeScannerState extends State<BarcodeScanner> {
  /// The mobile scanner controller controller.
  late final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.all],
  );

  @override
  Widget build(BuildContext context) => BlurWidget(
    above: SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: CloseButton(
              onPress: widget.onCloseButtonPress,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ToggleFlashlightButton(controller: controller),
                  SwitchCameraButton(controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    child: Center(
      child: MobileScanner(
        onDetect: widget.onScan,
        onDetectError: widget.onScanError ?? printError,
        fit: BoxFit.contain,
        controller: controller,
        // scanWindow: scanWindow,
        errorBuilder: (context, error) => ScannerErrorWidget(error: error),
      ),
    ),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
