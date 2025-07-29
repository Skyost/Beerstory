import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/history_entry/repository.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/adaptive.dart';
import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:beerstory/widgets/editors/history_entry_edit.dart';
import 'package:beerstory/widgets/form_fields/beer_quantity.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

/// A widget that allows to display a history entry.
class HistoryEntryWidget extends ConsumerWidget with FTileMixin {
  /// The history entry.
  final HistoryEntry historyEntry;

  /// Creates a new history entry widget.
  const HistoryEntryWidget({
    super.key,
    required this.historyEntry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Beer? beer = ref.watch(beerRepositoryProvider.select((beers) => beers.value?.findByUuid(historyEntry.beerUuid)));
    return beer == null
        ? const SizedBox.shrink()
        : _HistoryEntryContent(
            object: beer,
            historyEntry: historyEntry,
          );
  }
}

/// A widget that allows to display a history entry content.
class _HistoryEntryContent extends BeerWidget {
  /// The history entry.
  final HistoryEntry historyEntry;

  /// Creates a new history entry content widget.
  const _HistoryEntryContent({
    required super.object,
    required this.historyEntry,
  });

  @override
  Widget? buildSuffix(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (historyEntry.quantity != null)
        Padding(
          padding: const EdgeInsets.only(bottom: kSpace),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: translations.history.page.total,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: translations.history.page.quantity(
                    prefix: historyEntry.moreThanQuantity ? '+' : '',
                    quantity: NumberFormat.decimalPattern().format(historyEntry.quantity),
                  ),
                ),
              ],
            ),
          ),
        ),
      BeerDegrees(
        beer: object,
        inBadge: true,
      ),
    ],
  );

  @override
  Widget buildDetailsWidget(BuildContext context, ScrollController scrollController) => _HistoryEntryDetailsWidget(
    historyEntryUuid: historyEntry.uuid,
    scrollController: scrollController,
  );
}

/// Allows to show a history entry details.
class _HistoryEntryDetailsWidget extends ConsumerWidget {
  /// The history entry UUID.
  final String historyEntryUuid;

  /// The scroll controller.
  final ScrollController? scrollController;

  /// Creates a new history entry widget instance.
  const _HistoryEntryDetailsWidget({
    required this.historyEntryUuid,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    HistoryEntry? historyEntry = ref.watch(historyProvider.select((history) => history.value?.findByUuid(historyEntryUuid)));
    if (historyEntry == null) {
      return const CenteredCircularProgressIndicator();
    }
    List<FButton> actions = [
      FButton(
        style: FButtonStyle.destructive(),
        child: Text(translations.misc.delete),
        onPress: () async {
          if (await showDeleteConfirmationDialog(context)) {
            ref.read(historyProvider.notifier).remove(historyEntry);
          }
        },
      ),
    ];
    Beer? beer = ref.watch(beerRepositoryProvider.select((beers) => beers.value?.findByUuid(historyEntry.beerUuid)));
    if (beer == null) {
      return const CenteredCircularProgressIndicator();
    }
    return ListView(
      controller: scrollController,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: kSpace),
          child: FDateField(
            initialDate: historyEntry.date,
            onChange: (date) async {
              await editHistoryEntry(context, ref, historyEntry.copyWith(date: date));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: kSpace),
          child: FTileGroup(
            label: Text(translations.bars.details.title),
            children: [
              FTile(
                title: Text(translations.history.dialog.beer.label),
                subtitle: Text(beer.name),
                suffix: const Icon(FIcons.chevronRight),
                onPress: () async {
                  String? newBeerUuid = await HistoryEntryBeerEditorDialog.show(
                    context: context,
                    beerUuid: historyEntry.beerUuid,
                  );
                  if (newBeerUuid != null && newBeerUuid != historyEntry.beerUuid && context.mounted) {
                    await editHistoryEntry(context, ref, historyEntry.copyWith(beerUuid: newBeerUuid));
                  }
                },
              ),
              FTile(
                title: Text(translations.history.dialog.quantity.label),
                subtitle: Text('${historyEntry.quantity} cL'),
                suffix: const Icon(FIcons.chevronRight),
                onPress: () async {
                  BeerQuantity? newQuantity = await HistoryEntryQuantityEditorDialog.show(
                    context: context,
                    quantity: historyEntry.quantity,
                  );
                  if (newQuantity?.value != historyEntry.quantity && context.mounted) {
                    await editHistoryEntry(context, ref, historyEntry.overwriteQuantity(quantity: newQuantity?.value));
                  }
                },
              ),
              FTile(
                title: Text(translations.history.dialog.times.label),
                subtitle: Text(historyEntry.times.toString()),
                suffix: const Icon(FIcons.chevronRight),
                onPress: () async {
                  int? newTimes = await HistoryEntryTimesEditorDialog.show(
                    context: context,
                    times: historyEntry.times,
                  );
                  if (newTimes != null && newTimes != historyEntry.times && context.mounted) {
                    await editHistoryEntry(context, ref, historyEntry.copyWith(times: newTimes));
                  }
                },
              ),
              FTile(
                suffix: FCheckbox(value: historyEntry.moreThanQuantity),
                title: Text(translations.history.dialog.moreThanQuantity.label),
                subtitle: Text(historyEntry.moreThanQuantity.toString()),
                onPress: () async {
                  await editHistoryEntry(context, ref, historyEntry.copyWith(moreThanQuantity: !historyEntry.moreThanQuantity));
                },
              ),
            ],
          ),
        ),
        actions.adaptiveWrapper,
      ],
    );
  }

  /// Edits a given history entry and shows a waiting overlay.
  Future<void> editHistoryEntry(BuildContext context, WidgetRef ref, HistoryEntry editedHistoryEntry) async {
    await showWaitingOverlay(
      context,
      future: ref.read(historyProvider.notifier).change(editedHistoryEntry),
    );
  }

  /// Shows a delete confirmation dialog.
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async =>
      (await showFDialog(
        context: context,
        builder: (context, style, animation) => FDialog.adaptive(
          body: Text(translations.history.deleteConfirm),
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
}
