import 'package:flutter/material.dart';

/// Allows to edit a date.
class DateFormField extends FormField<DateTime> {
  /// Creates a new date form field instance.
  DateFormField({
    super.key,
    super.validator,
    Function(DateTime)? onSaved,
    DateTime? value,
    Widget Function(DateTime date, VoidCallback onPressed) buttonBuilder = _createButton,
  }) : super(
          initialValue: value ?? DateTime.now(),
          builder: (FormFieldState<DateTime> state) => buttonBuilder(
            state.value!,
            () async {
              DateTime? date = await showDatePicker(
                context: state.context,
                initialDate: state.value!,
                firstDate: DateTime(1900),
                lastDate: DateTime(2200),
                helpText: MaterialLocalizations.of(state.context).dateHelpText.toUpperCase(),
                cancelText: MaterialLocalizations.of(state.context).cancelButtonLabel.toUpperCase(),
                confirmText: MaterialLocalizations.of(state.context).okButtonLabel.toUpperCase(),
              );

              if (date != null) {
                state.didChange(date);
              }
            },
          ),
          onSaved: (date) => onSaved?.call(date!),
        );

  /// The default button builder.
  static Widget _createButton(DateTime date, VoidCallback onPressed) => TextButton(
        onPressed: onPressed,
        child: Text(date.toString()),
      );
}
