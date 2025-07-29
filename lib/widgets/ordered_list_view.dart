import 'dart:async';
import 'dart:collection';

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/compare_fields.dart';
import 'package:beerstory/utils/searchable.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// An ordered and searchable listview.
class OrderedListView<T> extends StatefulWidget {
  /// The objects list.
  final List<T> objects;

  /// The item builder.
  final FTileMixin Function(T) builder;

  /// Whether to order the list in reverse order.
  final bool reverseOrder;

  /// The group items function.
  final List<GroupData<T>> Function(List<T>)? groupObjects;

  /// Returns the comparator that allows to compare two [T].
  final Comparator<T>? comparator;

  /// Creates a new ordered listview instance.
  const OrderedListView({
    super.key,
    required this.objects,
    required this.builder,
    this.reverseOrder = false,
    this.groupObjects,
    this.comparator,
  });

  @override
  State<StatefulWidget> createState() => _OrderedListViewState<T>();
}

/// The ordered listview state.
class _OrderedListViewState<T> extends State<OrderedListView<T>> {
  /// The current scroll controller.
  ScrollController scrollController = ScrollController();

  /// The search controller.
  late TextEditingController searchController = TextEditingController()
    ..addListener(() {
      if (searchController.value.text.isEmpty) {
        filterList();
        return;
      }

      typingTimer?.cancel();
      typingTimer = Timer(const Duration(milliseconds: 500), filterList);
    });

  /// The current typing timer.
  Timer? typingTimer;

  /// The ordered objects list.
  List<GroupData<T>>? orderedObjects;

  /// Whether to show the search box.
  bool get showSearchBox => isSubtype<T, Searchable>();

  @override
  void initState() {
    initialize();
    super.initState();
  }

  Future<void> initialize() async {
    filterList();
    if (showSearchBox) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.position.maxScrollExtent >= 110) {
          scrollController.jumpTo(110);
        }
      });
    }
  }

  @override
  void didUpdateWidget(OrderedListView<T> oldWidget) {
    filterList();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (orderedObjects == null) {
      return const CenteredCircularProgressIndicator();
    }

    List<Widget> children = [];
    if (orderedObjects!.length == 1 && orderedObjects!.firstOrNull?.label == null) {
      children.addAll(orderedObjects!.first.objects.map(widget.builder));
    } else {
      for (GroupData<T> data in orderedObjects!) {
        children.add(
          FTileGroup(
            label: data.label == null ? null : Text(data.label!),
            children: data.objects.map(widget.builder).toList(),
          ),
        );
      }
    }

    return ListView(
      controller: scrollController,
      children: [
        if (showSearchBox) _createSearchBox(context),
        ...children,
      ],
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    typingTimer?.cancel();
    super.dispose();
  }

  /// Creates the search box.
  Widget _createSearchBox(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: kSpace),
        child: FTextField(
          hint: translations.misc.search,
          controller: searchController,
          textInputAction: TextInputAction.search,
          suffixBuilder: (context, value, child) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpace / 2, vertical: kSpace),
            child: Icon(
              FIcons.search,
              color: value.$2.contains(WidgetState.focused) ? context.theme.colors.primary : null,
            ),
          ),
        ),
      );

  /// Orders and filters the current list.
  Future<void> filterList() async {
    setState(() => orderedObjects = null);

    List<T> objects = List<T>.from(widget.objects);

    if (searchController.text.isNotEmpty) {
      String request = searchController.text.toLowerCase();
      objects = (objects as List<Searchable>).find(request).cast<T>();
    }

    Comparator<T>? comparator = this.comparator;
    if (comparator != null) {
      objects.sort(comparator);
    }

    List<GroupData<T>> result = widget.groupObjects == null ? [GroupData(objects: objects)] : widget.groupObjects!(objects)..sort();
    setState(() => orderedObjects = result);
  }

  /// Returns the comparator that allows to compare two [T].
  Comparator<T>? get comparator {
    if (widget.comparator != null) {
      return widget.comparator;
    }
    if (isSubtype<T, Comparable<T>>()) {
      Comparator<T> result = (a, b) => Comparable.compare(a as Comparable<T>, b as Comparable<T>);
      if (widget.reverseOrder) {
        result = result.reverseComparator;
      }
      return result;
    }
    return null;
  }
}

/// A group data.
class GroupData<T> implements Comparable<GroupData> {
  /// The group objects.
  final List<T> objects;

  /// Creates a new group data instance.
  const GroupData({
    this.objects = const [],
  });

  /// Returns the group label.
  String? get label => null;

  @override
  int compareTo(GroupData other) => compareAccordingToFields(
        this,
        other,
        (data) => [
          data.label,
        ],
      );

  @override
  bool operator ==(Object other) {
    if (other is! GroupData) {
      return super == other;
    }
    return identical(this, other) || (label == other.label && listEquals(objects, other.objects));
  }

  @override
  int get hashCode => Object.hash(label, objects);
}

/// Allows to create a reverse comparator.
extension _ReverseOrder<T> on Comparator<T> {
  /// Returns the reverse comparator.
  Comparator<T> get reverseComparator => (a, b) => -this(a, b);
}
