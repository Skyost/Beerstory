import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history/entry.dart';
import 'package:beerstory/model/history/history.dart';
import 'package:beerstory/widgets/dialogs/beer_animation_dialog.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:beerstory/widgets/form_fields/checkbox.dart';
import 'package:beerstory/widgets/form_fields/date_form_field.dart';
import 'package:beerstory/widgets/label.dart';
import 'package:beerstory/widgets/large_button.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The history entry editor.
class HistoryEntryEditorDialog extends FormDialog {
  /// The date.
  final DateTime date;

  /// The history entry.
  final HistoryEntry historyEntry;

  /// Whether to show the "more than quantity" field.
  final bool showMoreThanQuantityField;

  /// The history entry internal constructor.
  const HistoryEntryEditorDialog._internal({
    required this.date,
    required this.historyEntry,
    required this.showMoreThanQuantityField,
  });

  @override
  FormDialogState<HistoryEntryEditorDialog> createState() => _HistoryEntryEditorState();

  /// Shows a history entry editor.
  static Future<bool> show({
    required BuildContext context,
    required DateTime date,
    required HistoryEntry historyEntry,
    bool showMoreThanQuantityField = true,
  }) async =>
      (await showDialog(
        context: context,
        builder: (context) => HistoryEntryEditorDialog._internal(
          date: date,
          historyEntry: historyEntry,
          showMoreThanQuantityField: showMoreThanQuantityField,
        ),
      )) ==
      true;

  /// Shows a history entry editor for a new entry.
  static Future<bool> newEntry({
    required BuildContext context,
    DateTime? date,
    required Beer beer,
  }) async {
    bool result = await show(
      context: context,
      date: date ?? DateTime.now(),
      historyEntry: HistoryEntry(beer: beer),
      showMoreThanQuantityField: false,
    );
    if (result && context.mounted) {
      await BeerAnimationDialog.show(context: context);
    }
    return result;
  }
}

/// The history entry editor.
class _HistoryEntryEditorState extends FormDialogState<HistoryEntryEditorDialog> {
  /// The available quantities.
  static final Map<double, String> quantities = {
    33.0: 'historyEntryDialog.quantity.quantities.bottle',
    50.0: 'historyEntryDialog.quantity.quantities.halfPint',
    100.0: 'historyEntryDialog.quantity.quantities.pint',
  };

  /// The quantity field key.
  final GlobalKey quantityFieldKey = GlobalKey();

  /// The current date.
  late DateTime date;

  /// Whether to show more details.
  bool showMore = false;

  /// Whether to show the custom quantity field.
  bool showCustomQuantityField = false;

  @override
  void initState() {
    super.initState();
    date = widget.date;
  }

  @override
  List<Widget> createChildren(BuildContext context) {
    BeerRepository beerRepository = ref.watch(beerRepositoryProvider);
    return [
      BeerImage(
        beer: beerRepository.findByUuid(widget.historyEntry.beerUuid)!,
        radius: 100,
      ),
      const LabelWidget(
        icon: Icons.list,
        textKey: 'historyEntryDialog.beer.label',
      ),
      DropdownButtonFormField<String>(
        value: widget.historyEntry.beerUuid,
        items: [
          for (Beer beer in beerRepository.objects)
            DropdownMenuItem<String>(
              value: beer.uuid,
              child: Text(beer.name),
            ),
        ],
        onChanged: (value) {},
        onSaved: (value) => widget.historyEntry.beerUuid = value!,
      ),
      if (showMore) ...[
        const LabelWidget(
          icon: Icons.local_bar,
          textKey: 'historyEntryDialog.quantity.label',
        ),
        DropdownButtonFormField<double>(
          key: quantityFieldKey,
          value: widget.historyEntry.quantity == null || quantities.keys.contains(widget.historyEntry.quantity) ? widget.historyEntry.quantity : -1,
          items: [
            DropdownMenuItem<double>(
              value: null,
              child: Text(context.getString('historyEntryDialog.quantity.empty')),
            ),
            for (MapEntry<double, String> quantity in quantities.entries)
              DropdownMenuItem<double>(
                value: quantity.key,
                child: Text(context.getString(quantity.value)),
              ),
            DropdownMenuItem<double>(
              value: -1,
              child: Text(context.getString('historyEntryDialog.quantity.quantities.custom')),
            ),
          ],
          onChanged: (value) {
            setState(() => showCustomQuantityField = value == -1);
            (quantityFieldKey.currentState as FormFieldState).didChange(value);
          },
          onSaved: (value) {
            if (value != -1) {
              widget.historyEntry.quantity = value;
            }
          },
        ),
        if (showCustomQuantityField)
          TextFormField(
            decoration: InputDecoration(hintText: context.getString('historyEntryDialog.quantity.hint')),
            initialValue: widget.historyEntry.quantity != null && widget.historyEntry.quantity! > 0 ? widget.historyEntry.quantity.toString() : null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSaved: (value) {
              if (widget.historyEntry.quantity == null || widget.historyEntry.quantity! >= 0) {
                widget.historyEntry.quantity = double.tryParse(value ?? '?');
              }
            },
          ),
        const LabelWidget(
          icon: Icons.local_bar,
          textKey: 'historyEntryDialog.times.label',
        ),
        DropdownButtonFormField<int>(
          value: widget.historyEntry.times,
          items: List.generate(
            10,
            (index) => DropdownMenuItem<int>(
              value: index + 1,
              child: Text('${index + 1}x'),
            ),
          ),
          onChanged: (value) {},
          onSaved: (value) => widget.historyEntry.times = value!,
        ),
        DateFormField(
          value: date,
          buttonBuilder: (date, onPressed) => LargeButton(
            padding: const EdgeInsets.only(top: FormDialogState.padding),
            text: DateFormat.yMMMd(EzLocalization.of(context)?.locale.languageCode).format(date),
            onPressed: onPressed,
          ),
          onSaved: (value) {
            setState(() => date = value);
          },
        ),
        if (widget.showMoreThanQuantityField)
          Padding(
            padding: const EdgeInsets.only(top: FormDialogState.padding),
            child: CheckboxFormField(
              initialValue: widget.historyEntry.moreThanQuantity,
              onSaved: (value) => widget.historyEntry.moreThanQuantity,
              child: const LabelWidget(
                icon: Icons.add,
                textKey: 'historyEntryDialog.moreThanQuantity.label',
              ),
            ),
          ),
      ] else
        LargeButton(
          padding: const EdgeInsets.only(top: FormDialogState.padding),
          text: context.getString('action.more'),
          onPressed: () => setState(() {
            showMore = true;
          }),
        ),
    ];
  }

  @override
  void onSubmit() {
    History history = ref.read(historyProvider);
    history.removeEntry(widget.date, widget.historyEntry);
    history.insertEntry(date, widget.historyEntry);
    history.save();
  }
}
