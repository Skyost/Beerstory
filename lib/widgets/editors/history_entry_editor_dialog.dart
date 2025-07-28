import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/beer_animation_dialog.dart';
import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:beerstory/widgets/error.dart';
import 'package:beerstory/widgets/form_fields/checkbox.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// The history entry editor.
class HistoryEntryEditorDialog extends FormDialog<HistoryEntry> {
  /// Whether to show the "more than quantity" field.
  final bool showMoreThanQuantityField;

  /// The history entry internal constructor.
  const HistoryEntryEditorDialog._internal({
    required super.object,
    required this.showMoreThanQuantityField,
  });

  @override
  FormDialogState<HistoryEntry, HistoryEntryEditorDialog> createState() => _HistoryEntryEditorState();

  /// Shows a history entry editor.
  static Future<HistoryEntry?> show({
    required BuildContext context,
    required HistoryEntry historyEntry,
    bool? showMoreThanQuantityField,
  }) =>
      showFDialog<HistoryEntry>(
        context: context,
        builder: (context, style, animation) => HistoryEntryEditorDialog._internal(
          object: historyEntry,
          showMoreThanQuantityField: showMoreThanQuantityField ?? (historyEntry.quantity != null),
        ),
      );

  /// Shows a history entry editor for a new entry.
  static Future<HistoryEntry?> newEntry({
    required BuildContext context,
    required Beer beer,
  }) async {
    HistoryEntry? historyEntry = await show(
      context: context,
      historyEntry: HistoryEntry(beerUuid: beer.uuid),
      showMoreThanQuantityField: false,
    );
    if (historyEntry != null && context.mounted) {
      await BeerAnimationDialog.show(context: context);
    }
    return historyEntry;
  }
}

/// The history entry editor.
class _HistoryEntryEditorState extends FormDialogState<HistoryEntry, HistoryEntryEditorDialog> {
  /// The current history entry instance.
  late HistoryEntry historyEntry = widget.object.copyWith();

  /// The quantity field key.
  final GlobalKey quantityFieldKey = GlobalKey();

  /// Whether to show more details.
  bool showMore = false;

  /// Whether to show the custom quantity field.
  bool showCustomQuantityField = false;

  @override
  List<Widget> createChildren(BuildContext context) {
    AsyncValue<List<Beer>> beers = ref.watch(beerRepositoryProvider);
    if (beers.isLoading) {
      return [
        const CenteredCircularProgressIndicator(),
      ];
    }

    if (beers.hasError) {
      return [
        ErrorWidget(
          error: beers.error!,
          stackTrace: beers.stackTrace,
          onRetryPressed: () => ref.refresh(beerRepositoryProvider),
        ),
      ];
    }

    Map<double, String> quantities = this.quantities;
    List<Beer> beersList = beers.value!;
    return [
      BeerImage(
        beer: beersList.findByUuid(historyEntry.beerUuid),
        radius: 100,
      ),
      FSelectMenuTile<String>(
        prefix: Icon(FIcons.list),
        title: Text(translations.history.dialog.beer.label),
        initialValue: historyEntry.beerUuid,
        menu: [
          for (Beer beer in beersList)
            FSelectTile<String>(
              value: beer.uuid,
              title: Text(beer.name),
            ),
        ],
        onSaved: (value) => historyEntry = historyEntry.copyWith(beerUuid: value?.firstOrNull),
      ),
      if (showMore) ...[
        FSelectMenuTile<int>(
          prefix: Icon(FIcons.beer),
          initialValue: historyEntry.times,
          title: Text(translations.history.dialog.times.label),
          menu: [
            for (int i = 1; i < 11; i++)
              FSelectTile<int>(
                value: i,
                title: Text(i.toString()),
              ),
          ],
          onSaved: (value) => historyEntry = historyEntry.copyWith(times: value?.firstOrNull),
        ),
        FSelectMenuTile<double?>(
          prefix: Icon(FIcons.beer),
          title: Text(translations.history.dialog.quantity.label),
          key: quantityFieldKey,
          initialValue: historyEntry.quantity == null || quantities.keys.contains(historyEntry.quantity) ? historyEntry.quantity : -1,
          menu: [
            FSelectTile<double?>(
              value: null,
              title: Text(translations.history.dialog.quantity.empty),
            ),
            for (MapEntry<double, String> quantity in quantities.entries)
              FSelectTile<double>(
                value: quantity.key,
                title: Text(quantity.value),
              ),
            FSelectTile<double>(
              value: -1,
              title: Text(translations.history.dialog.quantity.quantities.custom),
            ),
          ],
          onChange: (value) {
            double? quantity = value.firstOrNull;
            setState(() => showCustomQuantityField = quantity == -1);
          },
          onSaved: (value) {
            double? quantity = value?.firstOrNull;
            if (quantity != -1) {
              historyEntry = historyEntry.copyWith(quantity: quantity);
            }
          },
        ),
        if (showCustomQuantityField)
          FTextFormField(
            hint: translations.history.dialog.quantity.hint,
            initialText: historyEntry.quantity != null && historyEntry.quantity! > 0 ? historyEntry.quantity!.toIntIfPossible().toString() : null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSaved: (value) {
              if (historyEntry.quantity == null || historyEntry.quantity! >= 0) {
                historyEntry.copyWith(quantity: historyEntry.calculateTrueQuantity(double.tryParse(value ?? '')));
              }
            },
          ),
        FDateField(
          initialDate: historyEntry.date,
          onSaved: (value) => historyEntry = historyEntry.copyWith(date: value),
        ),
        if (widget.showMoreThanQuantityField)
          CheckboxFormField(
            initialValue: historyEntry.moreThanQuantity,
            onSaved: (value) => historyEntry = historyEntry.copyWith(moreThanQuantity: value),
            label: Text(translations.history.dialog.moreThanQuantity.label),
          ),
      ] else
        FButton(
          child: Text(translations.misc.more),
          onPress: () {
            setState(() => showMore = true);
          },
        ),
    ];
  }

  /// The available quantities.
  Map<double, String> get quantities => {
        33.0: translations.history.dialog.quantity.quantities.bottle,
        50.0: translations.history.dialog.quantity.quantities.halfPint,
        100.0: translations.history.dialog.quantity.quantities.pint,
      };

  @override
  HistoryEntry? onValidated() => historyEntry;
}
