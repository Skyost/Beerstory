import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/price/price.dart';
import 'package:beerstory/model/beer/price/repository.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/format.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/async_value_widget.dart';
import 'package:beerstory/widgets/editors/beer_prices.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:beerstory/widgets/empty.dart';
import 'package:beerstory/widgets/repository/repository_object.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:forui/forui.dart';

/// Allows to display the prices of a beer.
class _BeerPricesDetailsWidget extends PricesDetailsWidget<Bar> {
  /// The beer UUID.
  final String beerUuid;

  /// Creates a new beer prices details widget instance.
  const _BeerPricesDetailsWidget({
    super.scrollController,
    required this.beerUuid,
  }) : super._();

  @override
  String buildTitle(BeerPrice beerPrice, List<Bar> availableObjects) => NumberFormat.formatPrice(beerPrice.amount);

  @override
  String? buildSubtitle(BeerPrice beerPrice, List<Bar> availableObjects) {
    Bar? bar = availableObjects.firstWhereOrNull(
      (bar) => bar.uuid == beerPrice.barUuid,
    );
    return bar?.name;
  }

  @override
  BeerPrice createNewBeerPrice(List<Bar> availableObjects) => BeerPrice(
    beerUuid: beerUuid,
    barUuid: availableObjects.firstOrNull?.uuid,
  );

  @override
  ProviderListenable<AsyncValue<List<BeerPrice>>> get objectProvider => beerPricesFromBeerProvider(beerUuid);

  @override
  AsyncNotifierProvider<BarRepository, List<Bar>> get availableObjectsRepositoryProvider => barRepositoryProvider;
}

/// Allows to display the prices of a bar.
class _BarPricesDetailsWidget extends PricesDetailsWidget<Beer> {
  /// Returned when the beer is unknown.
  static const String unknownBeer = 'Beer';

  /// The bar UUID.
  final String barUuid;

  /// Creates a new bar prices details widget instance.
  const _BarPricesDetailsWidget({
    super.scrollController,
    required this.barUuid,
  }) : super._();

  @override
  String buildTitle(BeerPrice beerPrice, List<Beer> availableObjects) {
    Beer? beer = availableObjects.firstWhereOrNull(
      (beer) => beer.uuid == beerPrice.beerUuid,
    );
    return beer?.name ?? unknownBeer;
  }

  @override
  String? buildSubtitle(BeerPrice beerPrice, List<Beer> availableObjects) => NumberFormat.formatPrice(beerPrice.amount);

  @override
  BeerPrice createNewBeerPrice(List<Beer> availableObjects) => BeerPrice(
    barUuid: barUuid,
    beerUuid: availableObjects.first.uuid,
  );

  @override
  ProviderListenable<AsyncValue<List<BeerPrice>>> get objectProvider => beerPricesFromBarProvider(barUuid);

  @override
  AsyncNotifierProvider<BeerRepository, List<Beer>> get availableObjectsRepositoryProvider => beerRepositoryProvider;
}

/// Allows to display the beer prices details.
abstract class PricesDetailsWidget<T extends HasName> extends DetailsWidget<BeerPrice, List<BeerPrice>> {
  /// The scroll controller.
  final ScrollController? scrollController;

  /// Creates a new prices details widget instance.
  const PricesDetailsWidget._({
    super.key,
    this.scrollController,
  });

  /// Creates a new prices details widget instance.
  static PricesDetailsWidget create<T extends HasName>({
    required ScrollController? scrollController,
    required String objectUuid,
  }) {
    if (isSubtype<T, Beer>()) {
      return _BeerPricesDetailsWidget(
        scrollController: scrollController,
        beerUuid: objectUuid,
      );
    } else if (isSubtype<T, Bar>()) {
      return _BarPricesDetailsWidget(
        scrollController: scrollController,
        barUuid: objectUuid,
      );
    }
    throw ArgumentError('$T is not Beer or Bar.');
  }

  /// Builds the title of the price.
  String buildTitle(BeerPrice beerPrice, List<T> availableObjects);

  /// Builds the subtitle of the price.
  String? buildSubtitle(BeerPrice beerPrice, List<T> availableObjects) => null;

  /// Creates a new beer price.
  BeerPrice createNewBeerPrice(List<T> availableObjects);

  @override
  AsyncNotifierProvider<Repository<BeerPrice>, List<BeerPrice>> get repositoryProvider => beerPriceRepositoryProvider;

  /// The corresponding repository provider.
  AsyncNotifierProvider<Repository<T>, List<T>> get availableObjectsRepositoryProvider;

  @override
  Widget buildChild(BuildContext context, WidgetRef ref, List<BeerPrice> beerPrices) => AsyncValueWidget(
    provider: availableObjectsRepositoryProvider,
    builder: (context, ref, availableObjects) {
      Widget child;
      if (beerPrices.isEmpty) {
        child = Center(
          child: EmptyWidget(
            text: translations.beerPrices.details.empty,
          ),
        );
      } else {
        List<FTileMixin> children = [];
        for (BeerPrice beerPrice in beerPrices) {
          String title = buildTitle(beerPrice, availableObjects);
          String? subtitle = buildSubtitle(beerPrice, availableObjects);
          if (kDebugMode) {
            subtitle = subtitle == null ? '' : '$subtitle\n\n';
            subtitle += beerPrice.uuid;
          }
          children.add(
            FTile(
              title: Text(title),
              subtitle: subtitle == null ? null : Text(subtitle),
              onPress: () async {
                FormDialogResult<BeerPrice> editedPrice = await BeerPriceEditorDialog.show<T>(
                  context: context,
                  beerPrice: beerPrice,
                  availableObjects: availableObjects,
                );
                if (editedPrice is! FormDialogResultSaved<BeerPrice> || !context.mounted) {
                  return;
                }
                if (editedPrice is DeletedBeerPrice) {
                  await deleteObject(context, ref, editedPrice.value);
                } else if (editedPrice.value != beerPrice) {
                  await editObject(context, ref, editedPrice.value);
                }
              },
            ),
          );
        }
        child = FTileGroup(
          label: Text(translations.beerPrices.details.label),
          children: children,
        );
      }
      return LayoutBuilder(
        builder: (context, constraints) => ListView(
          controller: scrollController,
          children: [
            Container(
              padding: const EdgeInsets.all(kSpace),
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 42,
              ),
              child: child,
            ),
            FButton(
              style: FButtonStyle.primary(),
              child: Text(translations.beerPrices.details.add),
              onPress: () async {
                FormDialogResult<BeerPrice> addedPrice = await BeerPriceEditorDialog.show<T>(
                  context: context,
                  beerPrice: createNewBeerPrice(availableObjects),
                  availableObjects: availableObjects,
                  showDeleteButton: false,
                );
                if (addedPrice is FormDialogResultSaved<BeerPrice> && context.mounted) {
                  await addObject(context, ref, addedPrice.value);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
