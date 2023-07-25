import 'dart:io';

import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/widgets/dialogs/wait_dialog.dart';
import 'package:beerstory/widgets/large_button.dart';
import 'package:code_scan/code_scan.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path_provider/path_provider.dart';

/// The beer barcode scan button.
class BeerBarcodeScanButton extends StatelessWidget {
  /// The text key.
  final String textKey;

  /// Triggered when the product is not found.
  final VoidCallback onProductNotFound;

  /// Triggered when there is an error.
  final VoidCallback onError;

  /// Triggered when the product has been found on the OpenFoodFacts server.
  final Function(Beer beer) onBeerFound;

  /// Creates a new beer barcode scan button instance.
  const BeerBarcodeScanButton({
    super.key,
    required this.textKey,
    required this.onProductNotFound,
    required this.onError,
    required this.onBeerFound,
  });

  @override
  Widget build(BuildContext context) => LargeButton(
        onPressed: () => CodeScanner(
          onScan: (code, details, controller) async {
            WaitDialog.show(context: context);
            OpenFoodFactsLanguage? language = OpenFoodFactsLanguage.fromOffTag(EzLocalization.of(context)!.locale.languageCode);
            if (code == null) {
              return;
            }


            ProductQueryConfiguration config = ProductQueryConfiguration(
              code,
              version: ProductQueryVersion.v3,
            );
            ProductResultV3 result = await OpenFoodAPIClient.getProductV3(config);
            if (result.product == null) {
              if (result.result?.id == ProductResultV3.resultProductNotFound) {
                onProductNotFound();
              } else {
                onError();
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
              return;
            }

            Product product = result.product!;
            String? name = product.productNameInLanguages?[language] ?? product.productName;
            if (product.brands != null) {
              String brand = product.brands!.split(',').first;
              name = name == null ? brand : '$brand - $name';
            }

            String? image;
            if (product.imageFrontUrl != null) {
              File file = File('${(await getApplicationDocumentsDirectory()).path}/${product.imageFrontUrl!.split('/').last}');
              await file.writeAsBytes((await http.get(Uri.parse(product.imageFrontUrl!))).bodyBytes);
              image = file.path;
            }

            if (context.mounted) {
              Navigator.pop(context);
            }
            onBeerFound(
              Beer(
                name: name ?? '?',
                image: image,
                tags: product.categoriesTagsInLanguages?[language] ?? product.categoriesTags,
              ),
            );
          },
          once: true,
        ),
        text: context.getString(textKey),
      );
}
