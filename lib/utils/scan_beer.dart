import 'dart:async';

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/price/price.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/scan/barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Contains some methods to scan a beer.
class BeerScan {
  /// Tries to scan a beer thanks to [BarcodeScanner].
  static Future<String?> scan(BuildContext context) async {
    OverlayEntry? entry;
    String? result;
    try {
      Completer<String> completer = Completer();
      entry = OverlayEntry(
        builder: (context) => BarcodeScanner(
          onScan: (barcodes) async {
            String barcode = barcodes.barcodes.firstOrNull?.rawValue ?? '';
            if (barcode.isEmpty) {
              return;
            }
            completer.complete(barcode);
          },
          onScanError: completer.completeError,
        ),
      );
      Overlay.of(context).insert(entry);
      result = await completer.future;
    } catch (ex, stackTrace) {
      printError(ex, stackTrace);
    } finally {
      entry?.remove();
    }
    return result;
  }

  /// Scans a beer and fetches its metadata on the Open Food Facts API.
  static Future<ScanResult> fetchFromOpenFoodFacts(String barcode) async {
    OpenFoodFactsLanguage? language = OpenFoodFactsLanguage.fromOffTag(translations.$meta.locale.languageCode);
    ProductQueryConfiguration config = ProductQueryConfiguration(
      barcode,
      version: ProductQueryVersion.v3,
    );
    ProductResultV3 result = await OpenFoodAPIClient.getProductV3(config);
    if (result.product == null) {
      return ScanResultError(errorId: result.result?.id);
    }

    Product product = result.product!;
    String? name = product.productNameInLanguages?[language] ?? product.productName ?? product.genericNameInLanguages?[language] ?? product.genericName;

    String? image;
    if (product.imageFrontUrl != null) {
      image = await BeerImage.copyImage(
        originalFilePath: product.imageFrontUrl!,
        filenamePrefix: barcode,
        source: 'openFoodFacts',
      );
    }

    String comment = '';
    if (product.genericName?.trimOrNullIfEmpty != null) {
      comment += '${translations.beers.scanComment.generic(generic: product.genericName!)}\n';
    }
    if (product.brands?.trimOrNullIfEmpty != null) {
      comment += '${translations.beers.scanComment.brand(brand: product.brands!.split(',').first)}\n';
    }
    if (product.quantity?.trimOrNullIfEmpty != null) {
      comment += '${translations.beers.scanComment.quantity(quantity: product.quantity!)}\n';
    }
    comment += '${translations.beers.scanComment.barcode(barcode: barcode)}\n';
    comment += translations.beers.scanComment.footer;

    GetPricesParameters getPricesParameters = GetPricesParameters()
      ..productCode = barcode
      ..additionalParameters = {
        'price_is_discounted': 'false',
      };
    MaybeError<GetPricesResult> prices = await OpenPricesAPIClient.getPrices(getPricesParameters);

    RegExp languageCategory = RegExp('^[a-z]{2}:');
    List<String> categories = product.categories?.split(', ') ?? [];
    Beer beer = Beer(
      name: name ?? '',
      image: image,
      tags: categories.where((category) => !category.startsWith(languageCategory)).toList(),
      comment: comment,
    );
    List<BeerPrice> beerPrices = [];
    if (!prices.isError && prices.value.items != null) {
      int count = prices.value.items!.length;
      if (count >= 2) {
        double sum = 0;
        for (Price price in prices.value.items!) {
          sum += price.price;
        }
        beerPrices.add(
          BeerPrice(
            beerUuid: beer.uuid,
            amount: double.parse((sum / count).toStringAsFixed(2)),
          ),
        );
      } else {
        for (Price price in prices.value.items!) {
          beerPrices.add(
            BeerPrice(
              beerUuid: beer.uuid,
              amount: price.price.toDouble(),
            ),
          );
        }
      }
    }

    return ScanResultSuccess(
      beer: beer,
      beerPrices: beerPrices,
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

  /// The beer prices.
  final List<BeerPrice> beerPrices;

  /// Creates a new scan result success instance.
  const ScanResultSuccess({
    required this.beer,
    required this.beerPrices,
  });
}
