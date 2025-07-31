import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/price/price.dart';
import 'package:beerstory/model/beer/price/repository.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/utils/format.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/editors/bar_edit.dart';
import 'package:beerstory/widgets/repository/beer_prices.dart';
import 'package:beerstory/widgets/repository/repository_object.dart';
import 'package:beerstory/widgets/scrollable_sheet_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Allows to show a bar.
class BarWidget extends RepositoryObjectWidget<Bar> {
  /// Creates a new bar widget instance.
  const BarWidget({
    super.key,
    required super.object,
  });

  @override
  Widget? buildPrefix(BuildContext context) => const Icon(FIcons.mapPin);

  @override
  Widget buildTitle(BuildContext context) => Text(object.name);

  @override
  Widget? buildSubtitle(BuildContext context) => (object.address?.isEmpty ?? true) ? Text(translations.bars.details.address.empty) : Text(object.address!);

  @override
  Widget buildDetailsWidget(BuildContext context, ScrollController scrollController) => _BarDetailsWidget(
    objectUuid: object.uuid,
    scrollController: scrollController,
    onBeerPricesPress: () {
      showFSheet(
        context: context,
        builder: (context) => ScrollableSheetContentWidget(
          builder: (context, scrollController) => PricesDetailsWidget.create<Bar>(
            scrollController: scrollController,
            objectUuid: object.uuid,
          ),
        ),
        side: FLayout.btt,
        mainAxisMaxRatio: null,
      );
    },
  );
}

/// Allows to show a bar details.
class _BarDetailsWidget extends RepositoryObjectDetailsWidget<Bar> {
  /// The beer prices press callback.
  final VoidCallback? onBeerPricesPress;

  /// Creates a new bar details widget instance.
  const _BarDetailsWidget({
    required super.objectUuid,
    super.scrollController,
    this.onBeerPricesPress,
  });

  @override
  String get deleteConfirmationMessage => translations.bars.deleteConfirm;

  @override
  AsyncNotifierProvider<Repository<Bar>, List<Bar>> get repositoryProvider => barRepositoryProvider;

  @override
  List<Widget> buildChildren(
    BuildContext context,
    WidgetRef ref,
    Bar object,
  ) => [
    FTileGroup(
      label: Text(translations.bars.details.title),
      children: [
        FTile(
          prefix: const Icon(FIcons.pencil),
          title: Text(translations.bars.details.name.label),
          subtitle: _BarName(bar: object),
          suffix: const Icon(FIcons.chevronRight),
          onPress: () async {
            String? newName = await BarNameEditorDialog.show(
              context: context,
              barName: object.name,
            );
            if (newName != null && newName != object.name && context.mounted) {
              await editObject(context, ref, object.copyWith(name: newName));
            }
          },
        ),
        FTile(
          prefix: const Icon(FIcons.mapPin),
          title: Text(translations.bars.details.address.label),
          subtitle: _BarAddress(bar: object),
          suffix: const Icon(FIcons.chevronRight),
          onPress: () async {
            String? newAddress = await BarAddressEditorDialog.show(
              context: context,
              barAddress: object.address,
            );
            if (newAddress != null && newAddress != object.address && context.mounted) {
              await editObject(
                context,
                ref,
                object.overwriteAddress(address: newAddress),
              );
            }
          },
        ),
        FTile(
          prefix: const Icon(FIcons.beer),
          title: Text(translations.beers.details.prices.label),
          subtitle: _BarBeerPrices(bar: object),
          suffix: const Icon(FIcons.chevronRight),
          onPress: onBeerPricesPress,
        ),
      ],
    ),
  ];

  @override
  List<FButton> buildActions(BuildContext context, WidgetRef ref, Bar object) => [
    FButton(
      onPress: () {
        String query = object!.name;
        if (object.address != null && object.address!.isNotEmpty) {
          query += ', ${object.address}';
        }
        if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
          launchUrl(
            Uri.https(
              'maps.apple.com',
              '',
              {'q': query},
            ),
          );
        } else {
          launchUrl(
            Uri.https(
              'google.com',
              'maps/search/',
              {'api': '1', 'query': query},
            ),
          );
        }
      },
      child: Text(translations.bars.details.showOnMap),
    ),
    ...super.buildActions(context, ref, object),
  ];
}

/// Allows to display the bar name.
class _BarName extends StatelessWidget {
  /// The bar.
  final Bar bar;

  /// Creates a new bar name widget instance.
  const _BarName({
    required this.bar,
  });

  @override
  Widget build(BuildContext context) => Text(bar.name);
}

/// Allows to display the bar address.
class _BarAddress extends StatelessWidget {
  /// The bar.
  final Bar bar;

  /// Creates a new bar address widget instance.
  const _BarAddress({
    required this.bar,
  });

  @override
  Widget build(BuildContext context) => (bar.address?.isEmpty ?? true) ? Text(translations.bars.details.address.empty) : Text(bar.address!);
}

/// Allows to display the bar beer prices.
class _BarBeerPrices extends ConsumerWidget {
  /// The bar.
  final Bar bar;

  /// Creates a new bar beer prices widget instance.
  const _BarBeerPrices({
    required this.bar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<BeerPrice>> prices = ref.watch(
      beerPricesFromBarProvider(bar.uuid),
    );
    if (!prices.hasValue || prices.value!.isEmpty) {
      return const SizedBox.shrink();
    }
    AsyncValue<List<Beer>> beers = ref.watch(beerRepositoryProvider);
    if (!beers.hasValue || beers.value!.isEmpty) {
      return const SizedBox.shrink();
    }
    String result = '';
    for (BeerPrice price in prices.value!) {
      Beer? beer = beers.value!.firstWhereOrNull(
        (beer) => beer.uuid == price.beerUuid,
      );
      if (beer == null) {
        continue;
      }
      result += '${beer.name} (${NumberFormat.formatPrice(price.amount)}), ';
    }
    result = result.trim();
    if (result.endsWith(',')) {
      result = result.substring(0, result.length - 1);
    }
    return Text(result);
  }
}
