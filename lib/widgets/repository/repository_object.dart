import 'package:beerstory/widgets/choice_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A repository object widget.
abstract class RepositoryObjectWidget extends ConsumerWidget {
  /// The background color.
  final Color? backgroundColor;

  /// The widget padding.
  final EdgeInsets? padding;

  /// Whether to add click listeners.
  final bool addClickListeners;

  /// Creates a new app widget instance.
  const RepositoryObjectWidget({
    super.key,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(20),
    this.addClickListeners = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget container = Container(
      padding: padding,
      color: backgroundColor,
      child: buildContent(context, ref),
    );

    if (!addClickListeners) {
      return container;
    }

    return InkWell(
      onLongPress: () => onLongPress(context, ref),
      onTap: () => onTap(context, ref),
      child: container,
    );
  }

  /// Builds the widget content.
  Widget buildContent(BuildContext context, WidgetRef ref);

  /// On long press listener.
  void onLongPress(BuildContext context, WidgetRef ref) => ChoiceDialog(
    choices: [
      Choice(
        text: 'action.edit',
        icon: Icons.edit,
        callback: () => onEdit(context, ref),
      ),
      Choice(
        text: 'action.delete',
        icon: Icons.delete,
        callback: () => onDelete(context, ref),
      ),
    ],
  ).show(context);

  /// On tap listener.
  void onTap(BuildContext context, WidgetRef ref) {}

  /// On tap listener.
  void onEdit(BuildContext context, WidgetRef ref);

  /// On tap listener.
  void onDelete(BuildContext context, WidgetRef ref);
}
