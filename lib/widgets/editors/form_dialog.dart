import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/widgets/adaptive_actions_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Represents a dialog that holds a form.
abstract class FormDialog<T> extends ConsumerStatefulWidget {
  /// The object instance.
  final T object;

  /// The dialog style.
  final FDialogStyle Function(FDialogStyle)? _style;

  /// The animation.
  final Animation<double>? _animation;

  /// Creates a new form dialog instance.
  const FormDialog({
    super.key,
    required this.object,
    FDialogStyle Function(FDialogStyle)? style,
    Animation<double>? animation,
  }) : _style = style,
       _animation = animation;

  @override
  FormDialogState<T, FormDialog<T>> createState();

  /// Shows a form dialog.
  static Future<FormDialogResult<T>> show<T>({
    required BuildContext context,
    required T object,
    required FormDialog<T> Function({
      required T object,
      FDialogStyle Function(FDialogStyle)? style,
      Animation<double>? animation,
    })
    builder,
  }) async {
    T? value = await showFDialog<T>(
      context: context,
      builder: (context, style, animation) => builder(
        object: object,
        style: style.call,
        animation: animation,
      ),
    );
    return value == null ? FormDialogResultCancelled<T>() : FormDialogResultSaved<T>(value: value);
  }
}

/// The form dialog state class.
abstract class FormDialogState<T, W extends FormDialog<T>> extends ConsumerState<W> {
  /// The form key.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    List<Widget> children = createChildren(context);
    return FDialog.raw(
      style: widget._style,
      animation: widget._animation,
      builder: (context, style) => Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(kSpace),
          shrinkWrap: true,
          children: [
            for (int i = 0; i < children.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i < children.length - 1 ? kSpace : kSpace * 2,
                ),
                child: children[i],
              ),
            AdaptiveActionsWrapper(
              actions: [
                FButton(
                  style: FButtonStyle.outline(),
                  child: Text(translations.misc.cancel),
                  onPress: () => Navigator.pop(context),
                ),
                FButton(
                  child: Text(translations.misc.ok),
                  onPress: () async {
                    if (formKey.currentState!.validate()) {
                      saveAndPop(context);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Saves the form and pops the dialog.
  void saveAndPop(BuildContext context) {
    formKey.currentState!.save();
    T? result = onSaved();
    if (result != null && context.mounted) {
      Navigator.pop(context, result);
    }
  }

  /// Creates the form children.
  List<Widget> createChildren(BuildContext context);

  /// Triggered when the form has been validated and saved.
  T? onSaved();
}

/// Represents a dialog result.
sealed class FormDialogResult<T> {
  /// Creates a new form dialog result instance.
  const FormDialogResult();
}

/// Represents a cancelled form dialog result.
class FormDialogResultCancelled<T> extends FormDialogResult<T> {}

/// Represents a saved form dialog result.
class FormDialogResultSaved<T> extends FormDialogResult<T> {
  /// The result.
  final T value;

  /// Creates a new saved form dialog result instance.
  const FormDialogResultSaved({
    required this.value,
  });
}
