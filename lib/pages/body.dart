import 'package:beerstory/model/repository.dart';
import 'package:beerstory/model/settings/group_objects.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/widgets/async_value_widget.dart';
import 'package:beerstory/widgets/empty.dart';
import 'package:beerstory/widgets/ordered_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Represents an app page.
abstract class ScaffoldBodyWidget<T extends RepositoryObject> extends ConsumerWidget {
  /// The prefixes.
  final List<Widget> prefixes;

  /// The suffixes.
  final List<Widget> suffixes;

  /// Whether to order the list in reverse order.
  final bool reverseOrder;

  /// Creates a new page instance.
  const ScaffoldBodyWidget({
    super.key,
    this.prefixes = const [],
    this.suffixes = const [],
    this.reverseOrder = false,
  });

  /// The corresponding repository provider.
  AsyncNotifierProvider<Repository<T>, List<T>> get repositoryProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueWidget(
    provider: repositoryProvider,
    builder: buildBodyWidget,
  );

  /// Builds the body widget (typically, a list view).
  Widget buildBodyWidget(BuildContext context, WidgetRef ref, List<T> objects, {Comparator<T>? comparator}) => LayoutBuilder(
    builder: (context, constraints) => OrderedListView<T>(
      objects: objects,
      builder: buildObjectWidget,
      reverseOrder: reverseOrder,
      emptyWidgetBuilder: (context, search) => Container(
        padding: const EdgeInsets.all(kSpace),
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight - 76,
        ),
        child: Center(
          child: EmptyWidget(
            text: getEmptyWidgetText(search),
          ),
        ),
      ),
      groupObjects: groupObjects(context, ref),
      comparator: comparator,
    ),
  );

  /// Builds the [object] widget.
  FTileMixin buildObjectWidget(T object);

  /// Returns the empty widget text.
  String getEmptyWidgetText(String? search);

  /// Allows to group the [objects].
  List<GroupData<T>> Function(List<T>)? groupObjects(BuildContext context, WidgetRef ref) => null;
}

/// Allows to group the objects by first letter.
mixin AlphabeticalGroup<T extends HasName> on ScaffoldBodyWidget<T> {
  @override
  List<GroupData<T>> Function(List<T>)? groupObjects(BuildContext context, WidgetRef ref) {
    bool groupObjects = ref.watch(groupObjectsSettingsEntryProvider).value == true;
    if (!groupObjects) {
      return super.groupObjects(context, ref);
    }
    return (objects) {
      Map<String, GroupData<T>> groupedEntries = {};
      for (T object in objects) {
        String firstLetter = object.name.substring(0, 1).toUpperCase();
        if (groupedEntries.containsKey(firstLetter)) {
          groupedEntries[firstLetter]!.objects.add(object);
        } else {
          groupedEntries[firstLetter] = GroupData(
            label: TextSpan(text: firstLetter),
            objects: [object],
          );
        }
      }
      return groupedEntries.values.toList()..sort();
    };
  }
}
