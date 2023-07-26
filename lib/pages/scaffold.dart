import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/utils/platform.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/editors/history_entry_editor_dialog.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'page.dart';

/// A simple scaffold that can display pages.
class PageScaffold extends StatefulWidget {
  /// The pages.
  final List<Page> pages;

  /// Creates a new page scaffold instance.
  const PageScaffold({
    super.key,
    required this.pages,
  }) : assert(pages.length > 0);

  @override
  State<StatefulWidget> createState() => _PageScaffoldState();
}

/// The pages scaffold state class.
class _PageScaffoldState extends State<PageScaffold> with SingleTickerProviderStateMixin {
  /// The current index.
  int currentPageIndex = 0;

  /// The tab controller.
  TabController? tabController;

  @override
  void initState() {
    if (widget.pages.length > 1) {
      tabController = TabController(
        vsync: this,
        length: widget.pages.length,
        initialIndex: currentPageIndex,
      );
      tabController!.addListener(() {
        setState(() => currentPageIndex = tabController!.index);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Page page = widget.pages[currentPageIndex];
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            context.getString(page.titleKey),
          ),
        ),
        actions: page.actions,
      ),
      floatingActionButton: _FloatingActionButton(),
      floatingActionButtonLocation: widget.pages.length > 1 ? FloatingActionButtonLocation.centerDocked : FloatingActionButtonLocation.centerFloat,
      body: widget.pages.length == 1
          ? widget.pages.first
          : TabBarView(
              controller: tabController,
              children: widget.pages,
            ),
      bottomNavigationBar: widget.pages.length > 1
          ? _BottomAppBar(
              pages: widget.pages,
              currentPageIndex: currentPageIndex,
              onPageSelected: (pageIndex) {
                if (pageIndex != currentPageIndex) {
                  currentPageIndex = pageIndex;
                  tabController?.animateTo(currentPageIndex);
                }
              },
            )
          : null,
      resizeToAvoidBottomInset: false,
    );
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }
}

/// The app floating action button.
class _FloatingActionButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => FloatingActionButton(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        heroTag: currentPlatform.isDesktop ? null : runtimeType.toString(),
        backgroundColor: Theme.of(context).colorScheme.darkPrimary,
        onPressed: () {
          BeerRepository repository = ref.read(beerRepositoryProvider);
          if (repository.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(context.getString('error.addBeerFirst')),
              backgroundColor: Theme.of(context).colorScheme.error,
            ));
            return;
          }
          HistoryEntryEditorDialog.newEntry(
            context: context,
            beer: repository.objects.first,
          );
        },
        child: SvgPicture.asset('assets/images/add.svg'),
      );
}

/// The app bottom bar, displayed when there is more than one page to show.
class _BottomAppBar extends StatelessWidget {
  /// The pages.
  final List<Page> pages;

  /// The current page index.
  final int currentPageIndex;

  /// Triggered when a new page has been selected.
  final Function(int pageIndex) onPageSelected;

  /// Creates a new bottom app bar instance.
  const _BottomAppBar({
    required this.pages,
    required this.currentPageIndex,
    required this.onPageSelected,
  }) : assert(pages.length >= 2);

  @override
  Widget build(BuildContext context) => BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < pages.length; i++)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: i == currentPageIndex ? Theme.of(context).colorScheme.darkPrimary : null,
                    foregroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    pages[i].icon,
                    color: Colors.white,
                  ),
                  label: Text(
                    context.getString(pages[i].titleKey),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                  onPressed: () => onPageSelected(i),
                )
            ],
          ),
        ),
      );
}
