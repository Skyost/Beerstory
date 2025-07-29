// ignore_for_file: prefer_const_constructors

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/widgets/beer_animation_dialog.dart';
import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:beerstory/widgets/error.dart';
import 'package:beerstory/widgets/form_fields/beer_quantity.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// The add history entry dialog.
class AddHistoryEntryDialog extends FormDialog<HistoryEntry> {
  /// Whether to show the "more than quantity" field.
  final bool showMoreThanQuantityField;

  /// The history entry internal constructor.
  const AddHistoryEntryDialog._({
    required super.object,
    required this.showMoreThanQuantityField,
    super.style,
    super.animation,
  });

  @override
  FormDialogState<HistoryEntry, AddHistoryEntryDialog> createState() => _AddHistoryEntryDialogState();

  /// Shows a history entry editor.
  static Future<HistoryEntry?> show({
    required BuildContext context,
    required HistoryEntry historyEntry,
    bool? showMoreThanQuantityField,
    bool showAnimationDialog = false,
  }) async {
    HistoryEntry? result = await showFDialog<HistoryEntry>(
      context: context,
      builder: (context, style, animation) => AddHistoryEntryDialog._(
        object: historyEntry,
        showMoreThanQuantityField: showMoreThanQuantityField ?? (historyEntry.quantity != null),
        style: style.call,
        animation: animation,
      ),
    );
    if (showAnimationDialog && result != null && context.mounted) {
      await BeerAnimationDialog.show(context: context);
    }
    return result;
  }
}

/// The history entry editor.
class _AddHistoryEntryDialogState extends FormDialogState<HistoryEntry, AddHistoryEntryDialog> {
  /// The current history entry instance.
  late HistoryEntry historyEntry = widget.object.copyWith();

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

    List<Beer> beersList = beers.value!;
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: kSpace * 2),
        child: BeerImage(
          beer: beersList.findByUuid(historyEntry.beerUuid),
          radius: 100,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: kSpace),
        child: FSelectMenuTile<String>(
          prefix: Icon(FIcons.beer),
          label: Text(translations.history.dialog.beer.label),
          initialValue: historyEntry.beerUuid,
          maxHeight: MediaQuery.sizeOf(context).height,
          title: Text(translations.history.dialog.beer.title),
          detailsBuilder: (_, values, _) {
            String? name = beers.value!.findByUuid(values.first)?.name;
            return name == null ? SizedBox.shrink() : Text(name);
          },
          menu: [
            for (Beer beer in beersList)
              FSelectTile<String>(
                value: beer.uuid,
                title: Text(beer.name),
              ),
          ],
          onSaved: (value) => historyEntry = historyEntry.copyWith(beerUuid: value?.firstOrNull),
        ),
      ),
    ];
  }

  @override
  HistoryEntry? onSaved() => historyEntry;
}

/// Allows to edit a history entry beer.
class HistoryEntryBeerEditorDialog extends FormDialog<String> {
  /// The history entry beer editor internal constructor.
  const HistoryEntryBeerEditorDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<String, HistoryEntryBeerEditorDialog> createState() => _HistoryEntryBeerEditorDialogState();

  /// Shows a new history entry beer editor.
  static Future<String?> show({
    required BuildContext context,
    required String beerUuid,
  }) => showFDialog<String>(
    context: context,
    builder: (context, style, animation) => HistoryEntryBeerEditorDialog._(
      object: beerUuid,
      style: style.call,
      animation: animation,
    ),
  );
}

/// The history entry beer editor dialog state.
class _HistoryEntryBeerEditorDialogState extends FormDialogState<String, HistoryEntryBeerEditorDialog> {
  /// The current beer UUID.
  late String beerUuid = widget.object;

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

    List<Beer> beersList = beers.value!;
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: kSpace * 2),
        child: BeerImage(
          beer: beersList.findByUuid(beerUuid),
          radius: 100,
        ),
      ),
      FSelectMenuTile<String>(
        prefix: Icon(FIcons.beer),
        label: Text(translations.history.dialog.beer.label),
        initialValue: beerUuid,
        maxHeight: MediaQuery.sizeOf(context).height,
        title: Text(translations.history.dialog.beer.title),
        detailsBuilder: (_, values, _) {
          String? name = beers.value!.findByUuid(values.first)?.name;
          return name == null ? SizedBox.shrink() : Text(name);
        },
        menu: [
          for (Beer beer in beersList)
            FSelectTile<String>(
              value: beer.uuid,
              title: Text(beer.name),
            ),
        ],
        onSaved: (value) => beerUuid = value?.firstOrNull ?? '',
      ),
    ];
  }

  @override
  String? onSaved() => beerUuid;
}

/// Allows to edit a history entry quantity.
class HistoryEntryQuantityEditorDialog extends FormDialog<BeerQuantity> {
  /// The history entry quantity editor internal constructor.
  const HistoryEntryQuantityEditorDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<BeerQuantity, HistoryEntryQuantityEditorDialog> createState() => _HistoryEntryQuantityEditorDialogState();

  /// Shows a new history entry quantity editor.
  static Future<BeerQuantity?> show({
    required BuildContext context,
    double? quantity,
  }) => showFDialog<BeerQuantity>(
    context: context,
    builder: (context, style, animation) => HistoryEntryQuantityEditorDialog._(
      object: BeerQuantity(value: quantity),
      style: style.call,
      animation: animation,
    ),
  );
}

/// The history entry quantity editor dialog state.
class _HistoryEntryQuantityEditorDialogState extends FormDialogState<BeerQuantity, HistoryEntryQuantityEditorDialog> {
  /// The current beer quantity.
  late BeerQuantity quantity = widget.object.copyWith();

  @override
  List<Widget> createChildren(BuildContext context) => [
    BeerQuantityFormField(
      label: Text(translations.history.dialog.quantity.label),
      title: Text(translations.history.dialog.quantity.title),
      initialValue: quantity,
      customQuantityHint: translations.history.dialog.quantity.hint,
      onSaved: (value) => quantity = BeerQuantity(value: value?.value),
      getQuantityTitle: (quantity) => switch (quantity) {
        EmptyBeerQuantity() => translations.history.dialog.quantity.empty,
        BottleBeerQuantity() => translations.history.dialog.quantity.quantities.bottle,
        HalfPintBeerQuantity() => translations.history.dialog.quantity.quantities.halfPint,
        PintBeerQuantity() => translations.history.dialog.quantity.quantities.pint,
        CustomBeerQuantity() => translations.history.dialog.quantity.quantities.custom,
      },
    ),
  ];

  @override
  BeerQuantity? onSaved() => quantity;
}

/// The history entry times editor dialog.
class HistoryEntryTimesEditorDialog extends FormDialog<int> {
  /// The history entry times editor internal constructor.
  const HistoryEntryTimesEditorDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<int, HistoryEntryTimesEditorDialog> createState() => _HistoryEntryTimesEditorDialogState();

  /// Shows a new history entry times editor.
  static Future<int?> show({
    required BuildContext context,
    required int times,
  }) => showFDialog<int>(
    context: context,
    builder: (context, style, animation) => HistoryEntryTimesEditorDialog._(
      object: times,
      style: style.call,
      animation: animation,
    ),
  );
}

/// The history entry times editor dialog state.
class _HistoryEntryTimesEditorDialogState extends FormDialogState<int, HistoryEntryTimesEditorDialog> {
  /// The current beer times.
  late int times = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    FSelectMenuTile<int>(
      prefix: Icon(FIcons.asterisk),
      initialValue: times,
      label: Text(translations.history.dialog.times.label),
      maxHeight: MediaQuery.sizeOf(context).height,
      title: Text(translations.history.dialog.times.title),
      detailsBuilder: (_, values, _) => Text(values.firstOrNull?.toString() ?? ''),
      menu: [
        for (int i = 1; i < 11; i++)
          FSelectTile<int>(
            value: i,
            title: Text(i.toString()),
          ),
      ],
      onSaved: (value) => times = value?.firstOrNull ?? 1,
    ),
  ];

  @override
  int? onSaved() => times;
}
