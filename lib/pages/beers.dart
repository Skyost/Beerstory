import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/pages/page.dart';
import 'package:beerstory/utils/scan_beer.dart';
import 'package:beerstory/widgets/editors/beer_editor_dialog.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// The beers page.
class BeersPage extends PageWidget<Beer, BeerRepository> {
  /// Creates a new beers page instance.
  BeersPage({
    super.key,
  }) : super(
          icon: FIcons.list,
          title: translations.beers.page.name,
          emptyMessage: translations.beers.page.empty,
          prefixes: const [
            HistoryButton(),
          ],
          suffixes: const [
            _ScanBeerButton(),
            _AddBeerButton(),
          ],
        );

  @override
  Widget createObjectWidget(Beer object, int position) => BeerWidget(
        object: object,
      );

  @override
  AsyncNotifierProvider<BeerRepository, List<Beer>> get repositoryProvider => beerRepositoryProvider;
}

/// The scan beer button.
class _ScanBeerButton extends ConsumerWidget {
  /// Creates a new scan beer button instance.
  const _ScanBeerButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) => FHeaderAction(
        icon: Icon(FIcons.barcode),
        onPress: () async {
          ScanResult result = await scanBeer(context);
          if (context.mounted) {
            context.handleScanResult(
              result,
              onSuccess: (beer) async {
                await showWaitingOverlay(
                  context,
                  future: ref.read(beerRepositoryProvider.notifier).add(beer),
                );
              },
            );
          }
        },
      );
}

/// The add beer button.
class _AddBeerButton extends ConsumerWidget {
  /// Creates a new add beer button instance.
  const _AddBeerButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) => FHeaderAction(
        icon: Icon(FIcons.plus),
        onPress: () async {
          Beer? beer = await BeerEditorDialog.show(context: context);
          if (beer != null && context.mounted) {
            showWaitingOverlay(
              context,
              future: ref.read(beerRepositoryProvider.notifier).add(beer),
            );
          }
        },
      );
}
