// ignore_for_file: prefer_const_constructors

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/price/price.dart';
import 'package:beerstory/model/beer/price/repository.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/adaptive.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:beerstory/widgets/editors/bar_edit.dart';
import 'package:beerstory/widgets/repository/beer_prices.dart';
import 'package:beerstory/widgets/repository/repository_object.dart';
import 'package:beerstory/widgets/scrollable_sheet_content.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Allows to show a bar.
class BarWidget extends RepositoryObjectWidget<Bar> {
  /// Creates a new bar widget instance.
  const BarWidget({
    super.key,
    required super.object,
  });

  @override
  Widget? buildPrefix(BuildContext context) => Icon(FIcons.mapPin);

  @override
  Widget buildTitle(BuildContext context) => Text(object.name);

  @override
  Widget? buildSubtitle(BuildContext context) => (object.address?.isEmpty ?? true) ? Text(translations.bars.details.address.empty) : Text(object.address!);

  @override
  Widget buildDetailsWidget(BuildContext context, ScrollController scrollController) => _BarDetailsWidget(
    barUuid: object.uuid,
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
class _BarDetailsWidget extends ConsumerWidget {
  /// The bar UUID.
  final String barUuid;

  /// The scroll controller.
  final ScrollController? scrollController;

  /// The beer prices press callback.
  final VoidCallback? onBeerPricesPress;

  /// Creates a new bar details widget instance.
  const _BarDetailsWidget({
    required this.barUuid,
    this.scrollController,
    this.onBeerPricesPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Bar? bar = ref.watch(barRepositoryProvider.select((bars) => bars.value?.findByUuid(barUuid)));
    if (bar == null) {
      return CenteredCircularProgressIndicator();
    }
    List<FButton> actions = [
      FButton(
        onPress: () => showBarOnMap(bar),
        child: Text(translations.bars.details.showOnMap),
      ),
      FButton(
        style: FButtonStyle.destructive(),
        child: Text(translations.misc.delete),
        onPress: () async {
          if (await showDeleteConfirmationDialog(context)) {
            ref.read(barRepositoryProvider.notifier).remove(bar);
          }
        },
      ),
    ];
    return ListView(
      controller: scrollController,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: kSpace),
          child: FTileGroup(
            label: Text(translations.bars.details.title),
            children: [
              FTile(
                prefix: Icon(FIcons.pencil),
                title: Text(translations.bars.details.name.label),
                subtitle: _BarName(bar: bar),
                suffix: Icon(FIcons.chevronRight),
                onPress: () async {
                  String? newName = await BarNameEditorDialog.show(
                    context: context,
                    barName: bar.name,
                  );
                  if (newName != null && newName != bar.name && context.mounted) {
                    await editBar(context, ref, bar.copyWith(name: newName));
                  }
                },
              ),
              FTile(
                prefix: Icon(FIcons.mapPin),
                title: Text(translations.bars.details.address.label),
                subtitle: _BarAddress(bar: bar),
                suffix: Icon(FIcons.chevronRight),
                onPress: () async {
                  String? newAddress = await BarAddressEditorDialog.show(
                    context: context,
                    barAddress: bar.address,
                  );
                  if (newAddress != null && newAddress != bar.address && context.mounted) {
                    await editBar(context, ref, bar.overwriteAddress(address: newAddress));
                  }
                },
              ),
              FTile(
                prefix: Icon(FIcons.beer),
                title: Text(translations.beers.details.prices.label),
                subtitle: _BarBeerPrices(bar: bar),
                suffix: Icon(FIcons.chevronRight),
                onPress: onBeerPricesPress,
              ),
            ],
          ),
        ),
        actions.adaptiveWrapper,
      ],
    );
  }

  /// Edits a given bar and shows a waiting overlay.
  Future<void> editBar(BuildContext context, WidgetRef ref, Bar editedBar) async {
    await showWaitingOverlay(
      context,
      future: ref.read(barRepositoryProvider.notifier).change(editedBar),
    );
  }

  /// Shows a delete confirmation dialog.
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async =>
      (await showFDialog(
        context: context,
        builder: (context, style, animation) => FDialog.adaptive(
          body: Text(translations.bars.deleteConfirm),
          actions: [
            FButton(
              style: FButtonStyle.outline(),
              child: Text(translations.misc.cancel),
              onPress: () => Navigator.pop(context, false),
            ),
            FButton(
              style: FButtonStyle.destructive(),
              child: Text(translations.misc.yes),
              onPress: () => Navigator.pop(context, true),
            ),
          ],
        ),
      )) ==
      true;

  /// Opens Google Maps to show the bar address.
  void showBarOnMap(Bar bar) {
    String query = bar.name;
    if (bar.address != null && bar.address!.isNotEmpty) {
      query += ', ${bar.address}';
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
  }
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
    NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: translations.$meta.locale.languageCode);
    AsyncValue<List<BeerPrice>> prices = ref.watch(beerPricesFromBarProvider(bar));
    if (!prices.hasValue || prices.value!.isEmpty) {
      return const SizedBox.shrink();
    }
    AsyncValue<List<Beer>> beers = ref.watch(beerRepositoryProvider);
    if (!beers.hasValue || beers.value!.isEmpty) {
      return const SizedBox.shrink();
    }
    String result = '';
    for (BeerPrice price in prices.value!) {
      Beer? beer = beers.value!.firstWhereOrNull((beer) => beer.uuid == price.beerUuid);
      if (beer == null) {
        continue;
      }
      result += '${beer.name} (${numberFormat.format(price.amount)}), ';
    }
    result = result.trim();
    if (result.endsWith(',')) {
      result = result.substring(0, result.length - 1);
    }
    return Text(result);
  }
}
