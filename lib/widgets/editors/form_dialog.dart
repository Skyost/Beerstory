import 'package:beerstory/widgets/label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a dialog that holds a form.
abstract class FormDialog extends ConsumerStatefulWidget {
  /// Creates a new form dialog instance.
  const FormDialog({
    super.key,
  });
}

/// The form dialog state class.
abstract class FormDialogState<T extends FormDialog> extends ConsumerState<T> {
  /// The padding amount.
  static const double padding = 30;

  /// The form key.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    List<Widget> children = createChildren(context);
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(padding),
            shrinkWrap: true,
            children: [
              for (int i = 0; i < children.length; i++)
                if (i > 0 && children[i] is LabelWidget)
                  Padding(
                    padding: const EdgeInsets.only(top: padding),
                    child: children[i],
                  )
                else
                  children[i],
            ],
          ),
        ),
      ),
      actions: [
        if (createCancelButton)
          TextButton(
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel.toUpperCase()),
            onPressed: () => Navigator.pop(context, false),
          ),
        TextButton(
          child: Text(MaterialLocalizations.of(context).okButtonLabel.toUpperCase()),
          onPressed: () async {
            if (!formKey.currentState!.validate()) {
              return;
            }

            formKey.currentState!.save();
            onSubmit();

            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  /// Creates the form children.
  List<Widget> createChildren(BuildContext context);

  /// Triggered when the form is submitted.
  void onSubmit();

  /// Whether to create the cancel button.
  bool get createCancelButton => true;
}
