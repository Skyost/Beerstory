import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/format.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/async_value_widget.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// The add history entry dialog.
class AddHistoryEntryDialog extends FormDialog<HistoryEntry> {
  /// The history entry internal constructor.
  const AddHistoryEntryDialog._({
    required super.object,
    super.style,
    super.animation,
  });

  @override
  FormDialogState<HistoryEntry, AddHistoryEntryDialog> createState() => _AddHistoryEntryDialogState();

  /// Shows a history entry editor.
  static Future<FormDialogResult<HistoryEntry>> show({
    required BuildContext context,
    required HistoryEntry historyEntry,
    bool? showMoreThanQuantityField,
  }) => FormDialog.show(
    context: context,
    object: historyEntry,
    builder: AddHistoryEntryDialog._,
  );
}

/// The history entry editor.
class _AddHistoryEntryDialogState extends FormDialogState<HistoryEntry, AddHistoryEntryDialog> {
  /// The current history entry instance.
  late HistoryEntry historyEntry = widget.object.copyWith();

  @override
  List<Widget> createChildren(BuildContext context) {
    AsyncValue<List<Beer>> beers = ref.watch(beerRepositoryProvider);
    return buildAsyncValueWidgetList(
      asyncValue: beers,
      onRetryPressed: () => ref.refresh(beerRepositoryProvider),
      builder: (beersList) => [
        Padding(
          padding: const EdgeInsets.only(bottom: kSpace),
          child: BeerImageWidget(
            beer: beersList.findByUuid(historyEntry.beerUuid),
            radius: 100,
          ),
        ),
        FSelectMenuTile<String>(
          prefix: const Icon(FIcons.beer),
          label: Text(translations.history.dialog.beer.label),
          initialValue: historyEntry.beerUuid,
          maxHeight: MediaQuery.sizeOf(context).height,
          title: Text(translations.history.dialog.beer.title),
          detailsBuilder: (_, values, _) {
            String? name = beersList.findByUuid(values.first)?.name;
            return name == null ? const SizedBox.shrink() : Text(name);
          },
          menu: [
            for (Beer beer in beersList)
              FSelectTile<String>(
                value: beer.uuid,
                title: Text(beer.name),
              ),
          ],
          onSaved: (value) => historyEntry = historyEntry.copyWith(
            beerUuid: value?.firstOrNull,
          ),
        ),
        _BeerQuantityFormField(
          initialValue: BeerQuantity(value: historyEntry.quantity),
          onSaved: (value) => historyEntry = historyEntry.overwriteQuantity(
            quantity: value?.value,
          ),
        ),
        _BeerTimesFormField(
          initialValue: historyEntry.times,
          maxHeight: MediaQuery.sizeOf(context).height,
          onSaved: (value) => historyEntry = historyEntry.copyWith(
            times: value,
          ),
        ),
      ],
    );
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
  static Future<FormDialogResult<String>> show({
    required BuildContext context,
    required String beerUuid,
  }) => FormDialog.show(
    context: context,
    object: beerUuid,
    builder: HistoryEntryBeerEditorDialog._,
  );
}

/// The history entry beer editor dialog state.
class _HistoryEntryBeerEditorDialogState extends FormDialogState<String, HistoryEntryBeerEditorDialog> {
  /// The current beer UUID.
  late String beerUuid = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) {
    AsyncValue<List<Beer>> beers = ref.watch(beerRepositoryProvider);
    return buildAsyncValueWidgetList(
      asyncValue: beers,
      onRetryPressed: () => ref.refresh(beerRepositoryProvider),
      builder: (beersList) => [
        Padding(
          padding: const EdgeInsets.only(bottom: kSpace),
          child: BeerImageWidget(
            beer: beersList.findByUuid(beerUuid),
            radius: 100,
          ),
        ),
        FSelectMenuTile<String>(
          prefix: const Icon(FIcons.beer),
          label: Text(translations.history.dialog.beer.label),
          initialValue: beerUuid,
          maxHeight: MediaQuery.sizeOf(context).height,
          title: Text(translations.history.dialog.beer.title),
          detailsBuilder: (_, values, _) {
            String? name = beers.value!.findByUuid(values.first)?.name;
            return name == null ? const SizedBox.shrink() : Text(name);
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
      ],
    );
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
  static Future<FormDialogResult<BeerQuantity>> show({
    required BuildContext context,
    required BeerQuantity quantity,
  }) => FormDialog.show(
    context: context,
    object: quantity,
    builder: HistoryEntryQuantityEditorDialog._,
  );
}

/// The history entry quantity editor dialog state.
class _HistoryEntryQuantityEditorDialogState extends FormDialogState<BeerQuantity, HistoryEntryQuantityEditorDialog> {
  /// The current beer quantity.
  late BeerQuantity quantity = widget.object.copyWith();

  @override
  List<Widget> createChildren(BuildContext context) => [
    _BeerQuantityFormField(
      initialValue: quantity,
      onSaved: (value) => quantity = value ?? const UnspecifiedBeerQuantity(),
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
  static Future<FormDialogResult<int>> show({
    required BuildContext context,
    required int times,
  }) => FormDialog.show(
    context: context,
    object: times,
    builder: HistoryEntryTimesEditorDialog._,
  );
}

/// The history entry times editor dialog state.
class _HistoryEntryTimesEditorDialogState extends FormDialogState<int, HistoryEntryTimesEditorDialog> {
  /// The current beer times.
  late int times = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    _BeerTimesFormField(
      initialValue: times,
      maxHeight: MediaQuery.sizeOf(context).height,
      onSaved: (value) => times = value,
    ),
  ];

  @override
  int? onSaved() => times;
}

/// The beer quantity form field.
class _BeerQuantityFormField extends FormField<BeerQuantity> {
  /// Creates a new beer quantity form field instance.
  _BeerQuantityFormField({
    FormFieldSetter<BeerQuantity>? onSaved,
    super.validator,
    super.initialValue = const UnspecifiedBeerQuantity(),
  }) : super(
         builder: (state) {
           CustomBeerQuantity customBeerQuantity = CustomBeerQuantity(
             value: state.value?.value,
           );
           return Column(
             spacing: kSpace,
             children: [
               FSelectMenuTile<BeerQuantity>(
                 onSaved: state.value is CustomBeerQuantity ? null : (quantities) => onSaved?.call(quantities?.firstOrNull),
                 validator: (quantities) => validator?.call(quantities?.firstOrNull),
                 prefix: const Icon(FIcons.rotateCcw),
                 label: Text(translations.history.dialog.quantity.label),
                 title: Text(translations.history.dialog.quantity.title),
                 initialValue: initialValue,
                 forceErrorText: state.errorText,
                 detailsBuilder: (_, values, _) {
                   BeerQuantity? quantity = values.firstOrNull;
                   return quantity == null ? const SizedBox.shrink() : Text(quantity._title);
                 },
                 menu: [
                   for (BeerQuantity quantity in const [
                     UnspecifiedBeerQuantity(),
                     BottleBeerQuantity(),
                     HalfPintBeerQuantity(),
                     PintBeerQuantity(),
                   ])
                     FSelectTile(
                       value: quantity,
                       title: Text(quantity._title),
                     ),
                   FSelectTile(
                     value: customBeerQuantity,
                     title: Text(customBeerQuantity._title),
                   ),
                 ],
                 onChange: (value) {
                   state.didChange(value.firstOrNull);
                 },
               ),
               if (state.value is CustomBeerQuantity)
                 FTextFormField(
                   hint: translations.history.dialog.quantity.hint,
                   initialText: state.value?.value == null ? null : NumberFormat.formatDouble(state.value!.value!),
                   keyboardType: const TextInputType.numberWithOptions(
                     decimal: true,
                   ),
                   onChange: (value) {
                     double? quantity = NumberFormat.tryParseDouble(value);
                     if (quantity != null && quantity < 0) {
                       quantity = null;
                     }
                     state.didChange(CustomBeerQuantity(value: quantity));
                   },
                   validator: (value) => numbersValidator(value, allowEmpty: false),
                   onSaved: (value) => onSaved?.call(state.value),
                 ),
             ],
           );
         },
       );
}

/// Represents a beer quantity.
sealed class BeerQuantity {
  /// The quantity value.
  final double? value;

  /// Creates a new beer quantity instance.
  const BeerQuantity._({
    this.value,
  });

  /// Creates a new beer quantity instance.
  factory BeerQuantity({
    double? value,
  }) => switch (value) {
    null => const UnspecifiedBeerQuantity(),
    BottleBeerQuantity.quantity => const BottleBeerQuantity(),
    HalfPintBeerQuantity.quantity => const HalfPintBeerQuantity(),
    PintBeerQuantity.quantity => const PintBeerQuantity(),
    _ => CustomBeerQuantity(value: value),
  };

  /// The title of the beer quantity.
  String get _title;

  /// Copies the current beer quantity instance.
  BeerQuantity copyWith({
    double? value,
  }) => BeerQuantity(
    value: value ?? this.value,
  );
}

/// Represents an unspecified beer quantity.
class UnspecifiedBeerQuantity extends BeerQuantity {
  /// Creates a new unspecified beer quantity instance.
  const UnspecifiedBeerQuantity() : super._();

  @override
  String get _title => translations.history.dialog.quantity.quantities.unspecified;
}

/// Represents a bottle beer quantity.
class BottleBeerQuantity extends BeerQuantity {
  /// The bottle quantity.
  static const double quantity = 33;

  /// Creates a new bottle beer quantity instance.
  const BottleBeerQuantity()
    : super._(
        value: quantity,
      );

  @override
  String get _title => translations.history.dialog.quantity.quantities.bottle;
}

/// Represents a half pint beer quantity.
class HalfPintBeerQuantity extends BeerQuantity {
  /// The half pint quantity.
  static const double quantity = 25;

  /// Creates a new half pint beer quantity instance.
  const HalfPintBeerQuantity()
    : super._(
        value: quantity,
      );

  @override
  String get _title => translations.history.dialog.quantity.quantities.halfPint;
}

/// Represents a pint beer quantity.
class PintBeerQuantity extends BeerQuantity {
  /// The pint quantity.
  static const double quantity = 50;

  /// Creates a new pint beer quantity instance.
  const PintBeerQuantity()
    : super._(
        value: quantity,
      );

  @override
  String get _title => translations.history.dialog.quantity.quantities.pint;
}

/// Represents a custom beer quantity.
class CustomBeerQuantity extends BeerQuantity {
  /// Creates a new custom beer quantity instance.
  const CustomBeerQuantity({
    super.value,
  }) : super._();

  @override
  String get _title => translations.history.dialog.quantity.quantities.custom;
}

/// The beer times form field.
class _BeerTimesFormField extends FSelectMenuTile<int> {
  /// Creates a new beer times form field instance.
  _BeerTimesFormField({
    Function(int)? onSaved,
    super.maxHeight,
    super.initialValue = 1,
  }) : super.builder(
         prefix: const Icon(FIcons.asterisk),
         label: Text(translations.history.dialog.times.label),
         title: Text(translations.history.dialog.times.title),
         detailsBuilder: (_, values, _) => Text(values.firstOrNull?.toString() ?? ''),
         menuBuilder: (context, index) => FSelectTile<int>(
           value: index + 1,
           title: Text('${index + 1}'),
         ),
         onSaved: (value) => onSaved?.call(value?.firstOrNull ?? 1),
       );
}
