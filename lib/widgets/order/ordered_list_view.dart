import 'dart:async';

import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:beerstory/widgets/order/findable.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';

/// An ordered and searchable listview.
class OrderedListView<T extends Findable> extends StatefulWidget {
  /// The listview items.
  final List<T> items;

  /// The item builder.
  final Widget Function(List<T>, int) itemBuilder;

  /// Whether to show the search box.
  final bool searchBox;

  /// Whether to order the list in reverse order.
  final bool reverseOrder;

  /// Creates a new ordered listview instance.
  const OrderedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.searchBox = true,
    this.reverseOrder = false,
  });

  @override
  State<StatefulWidget> createState() => _OrderedListViewState<T>();
}

/// The ordered listview state.
class _OrderedListViewState<T extends Findable> extends State<OrderedListView<T>> {
  /// The current scroll controller.
  ScrollController? scrollController;

  /// The search controller.
  TextEditingController? searchController;

  /// The current typing timer.
  Timer? typingTimer;

  /// The ordered items list.
  List<T>? orderedItems;

  @override
  void initState() {
    filterList();
    if (widget.searchBox) {
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

    if (widget.searchBox) {
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
        padding: const EdgeInsets.all(20),
        child: TextField(
          controller: searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
            ),
            suffixIcon: const Icon(
              Icons.search,
              color: Colors.grey,
            ),
            labelText: context.getString('page.search'),
            contentPadding: const EdgeInsets.all(10),
          ),
        ),
      );

  /// Orders and filters the current list.
  Future<void> filterList() async {
    setState(() => orderedItems = null);

    List<T> items = List<T>.from(widget.items);
    items.sort((a, b) => widget.reverseOrder ? b.orderKey.compareTo(a.orderKey) : a.orderKey.compareTo(b.orderKey));

    if (searchController != null && searchController!.text.isNotEmpty) {
      String request = searchController!.text.toLowerCase();
      items.retainWhere((sortable) {
        for (String searchTerm in sortable.searchTerms) {
          if (searchTerm.toLowerCase().contains(request)) {
            return true;
          }
        }
        return false;
      });
    }

    setState(() => orderedItems = items);
  }
}
