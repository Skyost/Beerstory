import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';

/// A simple choice dialog.
class ChoiceDialog {
  /// The choices.
  final List<Choice> choices;

  /// Creates a new choice dialog instance.
  const ChoiceDialog({
    required this.choices,
  });

  /// Shows a new choice dialog.
  void show(BuildContext context) => showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          children: choices,
        ),
      );
}

/// Represents a choice.
class Choice extends StatelessWidget {
  /// The choice text key.
  final String text;

  /// The choice icon.
  final IconData icon;

  /// The callback for when the choice has been pressed.
  final VoidCallback callback;

  /// Creates a new choice instance.
  const Choice({
    super.key,
    required this.text,
    required this.icon,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) => SimpleDialogOption(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.getString(text),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Icon(icon),
            ],
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
          callback();
        },
      );
}
