import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// A checkbox form field.
class CheckboxFormField extends FormField<bool> {
  /// Creates a new checkbox form field instance.
  CheckboxFormField({
    super.key,
    required Widget label,
    Widget? description,
    super.onSaved,
    super.validator,
    super.initialValue = false,
  }) : super(
          builder: (state) => FCheckbox(
            value: state.value == true,
            label: label,
            description: description,
            error: state.errorText != null ? Text(state.errorText!) : null,
            onChange: state.didChange,
          ),
        );
}
