import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:beerstory/widgets/label.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';

/// The bar editor.
class BarEditorDialog extends FormDialog {
  /// The bar.
  final Bar bar;

  /// The bar editor internal constructor.
  const BarEditorDialog._internal({
    required this.bar,
  });

  @override
  FormDialogState<BarEditorDialog> createState() => _BarEditorDialogState();

  /// Shows a bar editor.
  static Future<bool> show({
    required BuildContext context,
    Bar? bar,
  }) async =>
      (await showDialog(
        context: context,
        builder: (context) => BarEditorDialog._internal(
          bar: bar ?? Bar(name: ''),
        ),
      )) ==
      true;
}

/// The bar editor state.
class _BarEditorDialogState extends FormDialogState<BarEditorDialog> {
  @override
  List<Widget> createChildren(BuildContext context) => [
        const LabelWidget(
          icon: Icons.edit,
          textKey: 'barDialog.name.label',
        ),
        TextFormField(
          decoration: InputDecoration(hintText: context.getString('barDialog.name.hint')),
          initialValue: widget.bar.name,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.getString('error.empty');
            }
            return null;
          },
          onSaved: (value) => widget.bar.name = value ?? '?',
        ),
        const LabelWidget(
          icon: Icons.near_me,
          textKey: 'barDialog.address.label',
        ),
        TextFormField(
          decoration: InputDecoration(hintText: context.getString('barDialog.address.hint')),
          initialValue: widget.bar.address,
          minLines: 1,
          maxLines: 2,
          onSaved: (value) => widget.bar.address = value,
        ),
      ];

  @override
  void onSubmit() {
    BarRepository barRepository = ref.read(barRepositoryProvider);
    if (!barRepository.has(widget.bar)) {
      barRepository.add(widget.bar);
    }
    barRepository.save();
  }
}
