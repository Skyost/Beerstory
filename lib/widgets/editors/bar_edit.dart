import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/bar/bar.dart';
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
  static Future<FormDialogResult<Bar>> show({
    required BuildContext context,
    Bar? bar,
  }) => FormDialog.show(
    context: context,
    object: bar ?? Bar(),
    builder: AddBarDialog._,
  );
}

/// The add bar dialog state.
class _AddBarDialogState extends FormDialogState<Bar, AddBarDialog> {
  /// The current bar instance.
  late Bar bar = widget.object.copyWith();

  @override
  List<Widget> createChildren(BuildContext context) => [
    _BarNameFormField(
      initialText: widget.object.name,
      onSaved: (value) => bar = bar.copyWith(
        name: value?.trimOrNullIfEmpty,
      ),
    ),
    _BarAddressFormField(
      initialText: widget.object.address,
      onSaved: (value) => bar = bar.overwriteAddress(
        address: value?.trimOrNullIfEmpty,
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
  static Future<FormDialogResult<String>> show({
    required BuildContext context,
    required String name,
  }) => FormDialog.show(
    context: context,
    object: name,
    builder: BarNameEditorDialog._,
  );
}

/// The bar name editor dialog state.
class _BarNameEditorDialogState extends FormDialogState<String, BarNameEditorDialog> {
  /// The current bar name.
  late String? name = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    _BarNameFormField(
      initialText: name,
      onSaved: (value) => name = value?.trim(),
    ),
  ];

  @override
  String? onSaved() => name;
}

/// Allows to edit a bar address.
class BarAddressEditorDialog extends FormDialog<String?> {
  /// The bar address editor internal constructor.
  const BarAddressEditorDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<String?, BarAddressEditorDialog> createState() => _BarAddressEditorDialogState();

  /// Shows a new bar address editor.
  static Future<FormDialogResult<String?>> show({
    required BuildContext context,
    required String? address,
  }) => FormDialog.show(
    context: context,
    object: address,
    builder: BarAddressEditorDialog._,
  );
}

/// The bar address editor dialog state.
class _BarAddressEditorDialogState extends FormDialogState<String?, BarAddressEditorDialog> {
  /// The current bar address.
  late String? address = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    _BarAddressFormField(
      initialText: address,
      onSaved: (value) => address = value?.trimOrNullIfEmpty,
    ),
  ];

  @override
  String? onSaved() => address;
}

/// Allows to edit a bar comments.
class BarCommentsEditorDialog extends FormDialog<String?> {
  /// The bar comments editor internal constructor.
  const BarCommentsEditorDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<String?, BarCommentsEditorDialog> createState() => _BarCommentsEditorDialogState();

  /// Shows a new bar comments editor.
  static Future<FormDialogResult<String?>> show({
    required BuildContext context,
    required String? comments,
  }) => FormDialog.show(
    context: context,
    object: comments,
    builder: BarCommentsEditorDialog._,
  );
}

/// The bar comments editor dialog state.
class _BarCommentsEditorDialogState extends FormDialogState<String?, BarCommentsEditorDialog> {
  /// The current bar comments.
  late String? comments = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    _BarCommentsFormField(
      initialText: comments,
      onSaved: (value) => comments = value?.trimOrNullIfEmpty,
    ),
  ];

  @override
  String? onSaved() => comments;
}

/// The bar name form field.
class _BarNameFormField extends FTextFormField {
  /// Creates a new bar name form field instance.
  _BarNameFormField({
    super.initialText,
    FormFieldSetter<String>? onSaved,
  }) : super(
         label: Text(translations.bars.dialog.name.label),
         hint: translations.bars.dialog.name.hint,
         validator: emptyStringValidator,
         onSaved: (value) => onSaved?.call(value?.trimOrNullIfEmpty),
       );
}

/// The bar address form field.
class _BarAddressFormField extends FTextFormField {
  /// Creates a new bar address form field instance.
  _BarAddressFormField({
    super.initialText,
    FormFieldSetter<String>? onSaved,
  }) : super(
         label: Text(translations.bars.dialog.address.label),
         hint: translations.bars.dialog.address.hint,
         minLines: 1,
         maxLines: 3,
         onSaved: (value) => onSaved?.call(value?.trimOrNullIfEmpty),
       );
}

/// The bar comments form field.
class _BarCommentsFormField extends FTextFormField {
  /// Creates a new bar comments form field instance.
  _BarCommentsFormField({
    super.initialText,
    FormFieldSetter<String>? onSaved,
  }) : super(
         label: Text(translations.bars.dialog.comments.label),
         hint: translations.bars.dialog.comments.hint,
         minLines: 1,
         maxLines: 3,
         onSaved: (value) => onSaved?.call(value?.trimOrNullIfEmpty),
       );
}
