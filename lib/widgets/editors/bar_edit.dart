import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// The add bar dialog.
class AddBarDialog extends FormDialog<Bar> {
  /// The add bar dialog internal constructor.
  const AddBarDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<Bar, AddBarDialog> createState() => _AddBarDialogState();

  /// Shows a new bar editor.
  static Future<Bar?> show({
    required BuildContext context,
    Bar? beer,
  }) => showFDialog<Bar>(
    context: context,
    builder: (context, style, animation) => AddBarDialog._(
      object: beer ?? Bar(),
      style: style.call,
      animation: animation,
    ),
  );
}

/// The add bar dialog state.
class _AddBarDialogState extends FormDialogState<Bar, AddBarDialog> {
  /// The current bar instance.
  late Bar bar = widget.object.copyWith();

  @override
  List<Widget> createChildren(BuildContext context) => [
    Padding(
      padding: const EdgeInsets.only(bottom: kSpace),
      child: FTextFormField(
        label: Text(translations.bars.dialog.name.label),
        initialText: widget.object.name,
        hint: translations.bars.dialog.name.hint,
        validator: emptyStringValidator,
        onSaved: (value) => bar = bar.copyWith(
          name: value?.nullIfEmpty,
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(bottom: kSpace * 2),
      child: FTextFormField(
        label: Text(translations.bars.dialog.address.label),
        initialText: widget.object.address,
        hint: translations.bars.dialog.address.hint,
        minLines: 1,
        maxLines: 3,
        onSaved: (value) => bar = bar.overwriteAddress(
          address: value?.nullIfEmpty,
        ),
      ),
    ),
  ];

  @override
  Bar? onSaved() => bar;
}

/// Allows to edit a bar name.
class BarNameEditorDialog extends FormDialog<String> {
  /// The bar name editor internal constructor.
  const BarNameEditorDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<String, BarNameEditorDialog> createState() => _BarNameEditorDialogState();

  /// Shows a new bar name editor.
  static Future<String?> show({
    required BuildContext context,
    required String barName,
  }) => showFDialog<String>(
    context: context,
    builder: (context, style, animation) => BarNameEditorDialog._(
      object: barName,
      style: style.call,
      animation: animation,
    ),
  );
}

/// The bar name editor dialog state.
class _BarNameEditorDialogState extends FormDialogState<String, BarNameEditorDialog> {
  /// The current bar name.
  late String? barName = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    FTextFormField(
      label: Text(translations.bars.dialog.name.label),
      initialText: barName,
      hint: translations.bars.dialog.name.hint,
      validator: emptyStringValidator,
      onSaved: (value) => barName = value?.trim(),
    ),
  ];

  @override
  String? onSaved() => barName;
}

/// Allows to edit a bar address.
class BarAddressEditorDialog extends FormDialog<String> {
  /// The bar address.
  final String? barAddress;

  /// The bar address editor internal constructor.
  const BarAddressEditorDialog._({
    required super.object,
    this.barAddress,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<String, BarAddressEditorDialog> createState() => _BarAddressEditorDialogState();

  /// Shows a new bar address editor.
  static Future<String?> show({
    required BuildContext context,
    required String? barAddress,
  }) => showFDialog<String>(
    context: context,
    builder: (context, style, animation) => BarAddressEditorDialog._(
      object: barAddress ?? '',
      barAddress: barAddress,
      style: style.call,
      animation: animation,
    ),
  );
}

/// The bar address editor dialog state.
class _BarAddressEditorDialogState extends FormDialogState<String, BarAddressEditorDialog> {
  /// The current bar address.
  late String? barAddress = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    FTextFormField(
      label: Text(translations.bars.dialog.address.label),
      initialText: barAddress,
      hint: translations.bars.dialog.address.hint,
      minLines: 1,
      maxLines: 3,
      onSaved: (value) => barAddress = value?.trim(),
    ),
  ];

  @override
  String? onSaved() => barAddress;
}
