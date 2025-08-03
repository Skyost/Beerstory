import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/widgets/scan/barcode_scanner.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Contains some methods to scan a beer.
class BeerScan {
  /// Tries to scan a beer thanks to [BarcodeScanner].
  static Future<String?> _scan(BuildContext context) async =>
      (await showFDialog<String>(
        context: context,
        builder: (context, style, animation) => BarcodeScanner(
          onScan: (barcodes) async {
            String barcode = barcodes.barcodes.firstOrNull?.rawValue ?? '';
            if (barcode.isEmpty) {
              return;
            }

            Navigator.pop(context, barcode);
          },
        ),
      ));

  /// Scans a beer and fetches its metadata on the Open Food Facts API.
  static Future<ScanResult> scanAndFetchFromOpenFoodFacts(BuildContext context) async {
    String? barcode = await _scan(context);
    if (!context.mounted || barcode == null) {
      return ScanResultCancelled();
    }

    OpenFoodFactsLanguage? language = OpenFoodFactsLanguage.fromOffTag(TranslationProvider.of(context).locale.languageCode);
    ProductQueryConfiguration config = ProductQueryConfiguration(
      barcode,
      version: ProductQueryVersion.v3,
    );
    ProductResultV3 result = await showWaitingOverlay(
      context,
      future: OpenFoodAPIClient.getProductV3(config),
    );
    if (result.product == null) {
      return ScanResultError(errorId: result.result?.id);
    }

    Product product = result.product!;
    String? name = product.productNameInLanguages?[language] ?? product.productName;
    if (product.brands != null && product.brands != name) {
      String brand = product.brands!.split(',').first;
      name = name == null ? brand : '$brand - $name';
    }

    if (!context.mounted) {
      return ScanResultCancelled();
    }
    String? image;
    if (product.imageFrontUrl != null) {
      image = await showWaitingOverlay(
        context,
        future: BeerImage.copyImage(
          originalFilePath: product.imageFrontUrl!,
          filenamePrefix: barcode,
          source: 'openFoodFacts',
        ),
      );
    }

    return ScanResultSuccess(
      beer: Beer(
        name: name ?? '',
        image: image,
        tags: product.categories?.split(', ') ?? [],
      ),
    );
  }

  /// Handles a scan result.
  static void handleScanResult(BuildContext context, ScanResult result, {Function(Beer)? onSuccess}) async {
    switch (result) {
      case ScanResultNotFound():
        showFToast(
          context: context,
          title: Text(translations.error.openFoodFacts.notFound),
          style: (style) => style.copyWith(
            titleTextStyle: style.titleTextStyle.copyWith(
              color: context.theme.colors.error,
            ),
          ),
        );
        break;
      case ScanResultError():
        showFToast(
          context: context,
          title: Text(translations.error.openFoodFacts.genericError),
          style: (style) => style.copyWith(
            titleTextStyle: style.titleTextStyle.copyWith(
              color: context.theme.colors.error,
            ),
          ),
        );
        break;
      case ScanResultSuccess():
        onSuccess?.call(result.beer);
        break;
      default:
        break;
    }
  }
}

/// A scan result.
sealed class ScanResult {
  /// Creates a new scan result instance.
  const ScanResult();
}

/// Returned when an error occurs.
class ScanResultError extends ScanResult {
  /// The error id.
  final String? errorId;

  /// Creates a new scan result error instance.
  const ScanResultError._({
    this.errorId,
  });

  /// Creates a new scan result error instance.
  factory ScanResultError({String? errorId}) => switch (errorId) {
    ProductResultV3.resultProductNotFound => const ScanResultNotFound(),
    _ => ScanResultError._(errorId: errorId),
  };
}

/// Returned when the result is not found.
class ScanResultNotFound extends ScanResultError {
  /// Creates a new scan result not found instance.
  const ScanResultNotFound()
    : super._(
        errorId: ProductResultV3.resultProductNotFound,
      );
}

/// Returned when the scan is cancelled.
class ScanResultCancelled extends ScanResult {}

/// Returned when the scan is successful.
class ScanResultSuccess extends ScanResult {
  /// The scanned beer.
  final Beer beer;

  /// Creates a new scan result success instance.
  const ScanResultSuccess({
    required this.beer,
  });
}
