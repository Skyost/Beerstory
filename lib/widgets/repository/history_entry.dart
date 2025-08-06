import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/history_entry/repository.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/format.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:beerstory/widgets/editors/history_entry_edit.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:beerstory/widgets/repository/repository_object.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

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
    Beer? beer = ref.watch(
      beerRepositoryProvider.select(
        (beers) => beers.value?.findByUuid(historyEntry.beerUuid),
      ),
    );
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
  Widget buildPrefix(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: kSpace,
    children: [
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: historyEntry.times.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '×'),
          ],
        ),
        style: context.theme.typography.xs.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
      super.buildPrefix(context),
    ],
  );

  @override
  Widget buildDetailsWidget(BuildContext context, ScrollController scrollController) => _HistoryEntryDetailsWidget(objectUuid: historyEntry.uuid, scrollController: scrollController);
}

/// Allows to show a history entry details.
class _HistoryEntryDetailsWidget extends RepositoryObjectDetailsWidget<HistoryEntry> {
  /// Creates a new history entry widget instance.
  const _HistoryEntryDetailsWidget({
    required super.objectUuid,
    super.scrollController,
  });

  @override
  String get deleteConfirmationMessage => translations.history.deleteConfirm;

  @override
  AsyncNotifierProvider<Repository<HistoryEntry>, List<HistoryEntry>> get repositoryProvider => historyProvider;

  @override
  List<Widget> buildChildren(BuildContext context, WidgetRef ref, HistoryEntry object) => [
    FDateField(
      initialDate: object.date,
      onChange: (date) async {
        await editObject(context, ref, object.copyWith(date: date));
      },
    ),
    FTileGroup(
      label: Text(translations.bars.details.title),
      children: [
        _BeerTile(
          beerUuid: object.beerUuid,
          onPressed: (beer) async {
            FormDialogResult<String> newBeerUuid = await HistoryEntryBeerEditorDialog.show(
              context: context,
              beerUuid: beer.uuid,
            );
            if (newBeerUuid is FormDialogResultSaved<String> && newBeerUuid.value != beer.uuid && context.mounted) {
              await editObject(
                context,
                ref,
                object.copyWith(beerUuid: newBeerUuid.value),
              );
            }
          },
        ),
        FTile(
          prefix: const Icon(FIcons.rotateCcw),
          title: Text(translations.history.dialog.quantity.label),
          subtitle: Text(
            object.quantity == null
                ? translations.history.details.quantity.empty
                : translations.history.details.quantity.quantity(
                    quantity: NumberFormat.formatDouble(object.quantity!),
                  ),
          ),
          suffix: const Icon(FIcons.chevronRight),
          onPress: () async {
            FormDialogResult<BeerQuantity> newQuantity = await HistoryEntryQuantityEditorDialog.show(
              context: context,
              quantity: BeerQuantity(value: object.quantity),
            );
            if (newQuantity is FormDialogResultSaved<BeerQuantity> && newQuantity.value.value != object.quantity && context.mounted) {
              await editObject(
                context,
                ref,
                object.overwriteQuantity(quantity: newQuantity.value.value),
              );
            }
          },
        ),
        FTile(
          prefix: const Icon(FIcons.asterisk),
          title: Text(translations.history.dialog.times.label),
          subtitle: Text(object.times.toString()),
          suffix: const Icon(FIcons.chevronRight),
          onPress: () async {
            FormDialogResult<int> newTimes = await HistoryEntryTimesEditorDialog.show(
              context: context,
              times: object.times,
            );
            if (newTimes is FormDialogResultSaved<int> && newTimes.value != object.times && context.mounted) {
              await editObject(context, ref, object.copyWith(times: newTimes.value));
            }
          },
        ),
        FTile(
          prefix: const Icon(FIcons.diff),
          suffix: FCheckbox(value: object.moreThanQuantity),
          title: Text(translations.history.dialog.moreThanQuantity.label),
          subtitle: Text(
            object.moreThanQuantity ? translations.misc.yes : translations.misc.no,
          ),
          onPress: () async {
            await editObject(
              context,
              ref,
              object.copyWith(moreThanQuantity: !object.moreThanQuantity),
            );
          },
        ),
        FTile(
          prefix: const Icon(FIcons.messageSquare),
          title: Text(translations.history.dialog.comment.label),
          subtitle: (object.comment?.isEmpty ?? true) ? Text(translations.bars.details.comment.empty) : Text(object.comment!),
          suffix: const Icon(FIcons.chevronRight),
          onPress: () async {
            FormDialogResult<String?> newComment = await HistoryEntryCommentEditorDialog.show(
              context: context,
              comment: object.comment,
            );
            if (newComment is FormDialogResultSaved<String?> && newComment.value != object.comment && context.mounted) {
              await editObject(
                context,
                ref,
                object.overwriteComment(comment: newComment.value),
              );
            }
          },
        ),
        if (kDebugMode)
          FTile(
            prefix: const Icon(FIcons.hash),
            title: const Text('UUID'),
            subtitle: Text(object.uuid),
          ),
      ],
    ),
  ];
}

/// Allows to display the beer of a history entry.
class _BeerTile extends ConsumerWidget with FTileMixin {
  /// The beer UUID.
  final String beerUuid;

  /// Called when the tile is pressed.
  final Function(Beer)? onPressed;

  /// Creates a new beer widget instance.
  const _BeerTile({
    required this.beerUuid,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Beer? beer = ref.watch(
      beerRepositoryProvider.select(
        (beers) => beers.value?.findByUuid(beerUuid),
      ),
    );
    return beer == null
        ? const SizedBox.shrink()
        : FTile(
            prefix: const Icon(FIcons.beer),
            title: Text(translations.history.dialog.beer.label),
            subtitle: Text(beer.name),
            suffix: const Icon(FIcons.chevronRight),
            onPress: onPressed == null ? null : () => onPressed!(beer),
          );
  }
}
