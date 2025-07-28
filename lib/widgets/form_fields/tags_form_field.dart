import 'package:beerstory/spacing.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Allows to edit a list of tags.
class TagsFormField extends FormField<List<String>> {
  /// Creates a new tags form field instance.
  TagsFormField({
    super.key,
    super.validator,
    super.onSaved,
    super.initialValue,
    bool addAddForm = true,
    String? addFormHint,
    TextEditingController? addFormController,
    FocusNode? addFormFocusNode,
    Widget? label,
    Widget? emptyWidget,
    IconData? tagDeleteIcon,
  }) : super(
          builder: (FormFieldState<List<String>> state) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (addAddForm)
                Padding(
                  padding: EdgeInsets.only(bottom: kSpace / 2),
                  child: FTextFormField(
                    focusNode: addFormFocusNode,
                    label: label,
                    hint: addFormHint,
                    textInputAction: TextInputAction.send,
                    controller: addFormController,
                    onSubmit: (value) {
                      state.didChange(List.of(state.value ?? [])..add(value));
                      addFormController?.clear();
                      addFormFocusNode?.requestFocus();
                    },
                  ),
                ),
              if (state.value == null || state.value!.isEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: kSpace / 2),
                  child: emptyWidget ?? const SizedBox.shrink(),
                )
              else
                FLabel(
                  label: addAddForm ? null : label,
                  axis: Axis.horizontal,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: kSpace / 2,
                      runSpacing: kSpace / 2,
                      children: [
                        for (String tag in state.value ?? [])
                          FBadge(
                            child: Row(
                              children: [
                                Text(tag),
                                if (tagDeleteIcon != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: GestureDetector(
                                      onTap: () => state.didChange(state.value?..remove(tag)),
                                      child: Icon(
                                        tagDeleteIcon,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
}
