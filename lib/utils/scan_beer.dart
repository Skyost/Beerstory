import 'dart:io';

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/scan/barcode_scanner.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path/path.dart' as path;

/// Tries to scan a beer thanks to [BarcodeScanner].
Future<ScanResult> scanBeer(BuildContext context) async =>
    (await showFDialog<ScanResult>(
      context: context,
      builder: (context, style, animation) => BarcodeScanner(
        onScan: (barcodes) async {
          String barcode = barcodes.barcodes.firstOrNull?.rawValue ?? '';
          if (barcode.isEmpty) {
            return;
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
          if (!context.mounted) {
            return;
          }
          if (result.product == null) {
            if (result.result?.id == ProductResultV3.resultProductNotFound) {
              showFToast(
                context: context,
                title: Text(translations.error.openFoodFacts.notFound),
              );
            } else {
              showFToast(
                context: context,
                title: Text(translations.error.openFoodFacts.genericError),
              );
            }
            Navigator.pop(
              context,
              ScanResultError(errorId: result.result?.id),
            );
            return;
          }

          Product product = result.product!;
          String? name = product.productNameInLanguages?[language] ?? product.productName;
          if (product.brands != null && product.brands != name) {
            String brand = product.brands!.split(',').first;
            name = name == null ? brand : '$brand - $name';
          }

          String? image;
          if (product.imageFrontUrl != null) {
            image = await showWaitingOverlay(
              context,
              future: (() async {
                try {
                  Uri uri = Uri.parse(product.imageFrontUrl!);
                  String extension = path.extension(uri.pathSegments.last);
                  Directory directory = await Beer.getImagesTargetDirectory();
                  File file = File(path.join(directory.path, 'openFoodFacts', '$barcode$extension'));
                  file.parent.createSync(recursive: true);
                  await file.writeAsBytes((await http.get(uri)).bodyBytes);
                  return file.path;
                } catch (ex, stackTrace) {
                  printError(ex, stackTrace);
                }
                return null;
              })(),
            );
          }

          if (context.mounted) {
            Navigator.pop(
              context,
              ScanResultSuccess(
                beer: Beer(
                  name: name ?? '',
                  image: image,
                  tags: product.categories?.split(', ') ?? [],
                ),
              ),
            );
          }
        },
      ),
    )) ??
    ScanResultCancelled();

/// Allows to handle a scan result.
extension HandleScanResult on BuildContext {
  /// Handles a scan result.
  void handleScanResult(ScanResult result, {Function(Beer)? onSuccess}) async {
    switch (result) {
      case ScanResultNotFound():
        showFToast(
          context: this,
          title: Text(translations.error.openFoodFacts.notFound),
        );
        break;
      case ScanResultError():
        showFToast(
          context: this,
          title: Text(translations.error.openFoodFacts.genericError),
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
