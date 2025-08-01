import 'dart:math' as math;
import 'dart:ui';

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/spacing.dart';
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
}

/// The form dialog state class.
abstract class FormDialogState<T, W extends FormDialog<T>> extends ConsumerState<W> {
  /// The form key.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    List<Widget> children = createChildren(context);
    FlutterView window = PlatformDispatcher.instance.views.first;
    EdgeInsets viewInsets = EdgeInsets.fromViewPadding(
      window.viewInsets,
      window.devicePixelRatio,
    );
    return FDialog.adaptive(
      style: widget._style,
      animation: widget._animation,
      body: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: math.max(0, MediaQuery.sizeOf(context).height - 192 - viewInsets.bottom),
        ),
        child: Form(
          key: formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (int i = 0; i < children.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i < children.length - 1 ? kSpace : kSpace * 2,
                  ),
                  child: children[i],
                ),
            ],
          ),
        ),
      ),
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
