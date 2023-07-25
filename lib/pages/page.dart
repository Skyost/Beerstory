import 'package:beerstory/model/repository.dart';
import 'package:beerstory/model/repository_object.dart';
import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:beerstory/widgets/centered_message.dart';
import 'package:beerstory/widgets/order/ordered_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents an app page.
abstract class Page<T extends RepositoryObject> extends ConsumerWidget {
  /// The page icon.
  final IconData icon;

  /// The page title.
  final String titleKey;

  /// The empty message.
  final String emptyMessageKey;

  /// The actions.
  final List<Widget> actions;

  /// Whether to show the search box.
  final bool searchBox;

  /// Whether to order the list in reverse order.
  final bool reverseOrder;

  /// Creates a new page instance.
  const Page({
    super.key,
    required this.icon,
    required this.titleKey,
    required this.emptyMessageKey,
    required this.actions,
    this.searchBox = true,
    this.reverseOrder = false,
  });

  /// Allows to watch the corresponding repository.
  Repository<T> watchRepository(WidgetRef ref);

  /// Allows to create an object widget.
  Widget createObjectWidget(T object, int position);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Repository<T> repository = watchRepository(ref);
    if (!repository.isInitialized) {
      return const CenteredCircularProgressIndicator();
    }

    if (repository.isEmpty) {
      return CenteredMessage(textKey: emptyMessageKey);
    }

    return OrderedListView<T>(
      items: repository.objects.toList(),
      itemBuilder: (objects, position) => createObjectWidget(objects[position], position),
      searchBox: searchBox,
      reverseOrder: reverseOrder,
    );
  }
}
