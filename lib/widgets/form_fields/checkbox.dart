import 'package:flutter/material.dart';

/// A checkbox form field.
class CheckboxFormField extends FormField<bool> {
  /// Creates a new checkbox form field instance.
  CheckboxFormField({
    super.key,
    required Widget child,
    super.onSaved,
    super.validator,
    super.initialValue = false,
  }) : super(
          builder: (state) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: state.value,
            title: child,
            onChanged: state.didChange,
          ),
        );
}
