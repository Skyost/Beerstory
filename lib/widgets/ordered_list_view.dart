import 'dart:async';

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/searchable.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// An ordered and searchable listview.
class OrderedListView<T> extends StatefulWidget {
  /// The listview items.
  final List<T> items;

  /// The item builder.
  final Widget Function(List<T>, int) itemBuilder;

  /// Whether to order the list in reverse order.
  final bool reverseOrder;

  /// Creates a new ordered listview instance.
  const OrderedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.reverseOrder = false,
  });

  @override
  State<StatefulWidget> createState() => _OrderedListViewState<T>();
}

/// The ordered listview state.
class _OrderedListViewState<T> extends State<OrderedListView<T>> {
  /// The current scroll controller.
  ScrollController? scrollController;

  /// The search controller.
  TextEditingController? searchController;

  /// The current typing timer.
  Timer? typingTimer;

  /// The ordered items list.
  List<T>? orderedItems;

  /// Whether to show the search box.
  bool get showSearchBox => isSubtype<T, Searchable>();

  @override
  void initState() {
    filterList();
    if (showSearchBox) {
      scrollController = ScrollController();
      searchController = TextEditingController();

      searchController!.addListener(() {
        if (searchController!.value.text.isEmpty) {
          filterList();
          return;
        }

        typingTimer?.cancel();
        typingTimer = Timer(const Duration(milliseconds: 500), filterList);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController!.position.maxScrollExtent >= 110) {
          scrollController!.jumpTo(110);
        }
      });
    }
    super.initState();
  }

  @override
  void didUpdateWidget(OrderedListView<T> oldWidget) {
    filterList();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (orderedItems == null) {
      return const CenteredCircularProgressIndicator();
    }

    if (showSearchBox) {
      return ListView.builder(
        controller: scrollController,
        itemCount: orderedItems!.length + 1,
        itemBuilder: (context, position) => (position == 0 ? _createSearchBox(context) : widget.itemBuilder(orderedItems!, position - 1)),
      );
    }

    return ListView.builder(
      itemCount: orderedItems!.length,
      itemBuilder: (context, position) => widget.itemBuilder(orderedItems!, position),
    );
  }

  @override
  void dispose() {
    scrollController?.dispose();
    searchController?.dispose();
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
    setState(() => orderedItems = null);

    List<T> items = List<T>.from(widget.items);

    if (searchController != null && searchController!.text.isNotEmpty) {
      String request = searchController!.text.toLowerCase();
      items = (items as List<Searchable>).find(request) as List<T>;
    }

    Comparator<T>? comparator = this.comparator;
    if (comparator != null) {
      items.sort(comparator);
    }

    setState(() => orderedItems = items);
  }

  /// Returns the comparator that allows to compare two [T].
  Comparator<T>? get comparator {
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

/// Allows to create a reverse comparator.
extension _ReverseOrder<T> on Comparator<T> {
  /// Returns the reverse comparator.
  Comparator<T> get reverseComparator => (a, b) => -this(a, b);
}
