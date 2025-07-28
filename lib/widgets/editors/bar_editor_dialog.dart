import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// The bar editor.
class BarEditorDialog extends FormDialog<Bar> {
  /// The bar editor internal constructor.
  const BarEditorDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<Bar, BarEditorDialog> createState() => _BarEditorDialogState();

  /// Shows a bar editor.
  static Future<Bar?> show({
    required BuildContext context,
    Bar? bar,
  }) =>
      showFDialog<Bar>(
        context: context,
        builder: (context, style, animation) => BarEditorDialog._(
          object: bar ?? Bar(),
          style: style.call,
          animation: animation,
        ),
      );
}

/// The bar editor state.
class _BarEditorDialogState extends FormDialogState<Bar, BarEditorDialog> {
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return translations.error.empty;
              }
              return null;
            },
            onSaved: (value) => bar = bar.copyWith(
              name: value?.trim(),
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
            maxLines: 2,
            onSaved: (value) => bar = bar.overwriteAddress(
              address: value?.nullIfEmpty,
            ),
          ),
        ),
        // TODO edit prices button,
      ];

  @override
  Bar? onValidated() => bar;
}
