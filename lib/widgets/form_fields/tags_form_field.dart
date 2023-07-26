import 'package:beerstory/widgets/tag.dart';
import 'package:flutter/material.dart';

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
    Widget? emptyWidget,
    IconData? tagDeleteIcon,
  }) : super(
          builder: (FormFieldState<List<String>> state) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (addAddForm)
                TextFormField(
                  decoration: InputDecoration(hintText: addFormHint),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) => state.didChange((state.value ?? [])..add(value)),
                ),
              if (state.value == null || state.value!.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: addAddForm ? 10 : 0),
                  child: emptyWidget ?? const SizedBox.shrink(),
                )
              else
                Container(
                  width: MediaQuery.of(state.context).size.width,
                  padding: const EdgeInsets.only(top: 10),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (String tag in state.value ?? [])
                        TagWidget(
                          text: tag,
                          right: tagDeleteIcon == null
                              ? null
                              : Padding(
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
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
}
