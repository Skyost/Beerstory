import 'package:beerstory/widgets/scan/scanner_button_widgets.dart';
import 'package:beerstory/widgets/scan/scanner_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// A barcode scanner widget.
class BarcodeScanner extends StatefulWidget {
  /// Triggered when a barcode has been scanned.
  final Function(BarcodeCapture barcodes)? onScan;

  /// Creates a new barcode scanner instance.
  const BarcodeScanner({
    super.key,
    this.onScan,
  });

  @override
  State<StatefulWidget> createState() => _BarcodeScannerState();
}

/// The barcode scanner state.
class _BarcodeScannerState extends State<BarcodeScanner> {
  /// The mobile scanner controller controller.
  MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.all],
  );

  @override
  Widget build(BuildContext context) => Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: MobileScanner(
            onDetect: widget.onScan,
            fit: BoxFit.contain,
            controller: controller,
            // scanWindow: scanWindow,
            errorBuilder: (context, error, child) => ScannerErrorWidget(error: error),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
    );

  @override
  Future<void> dispose() async {
    await controller.dispose();
    super.dispose();
  }
}
