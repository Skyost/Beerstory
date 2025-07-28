import 'package:beerstory/pages/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:jovial_svg/jovial_svg.dart';

/// A simple scaffold that can display pages.
class PageScaffold extends StatefulWidget {
  /// The pages.
  final List<PageWidget> pages;

  /// Whether to show the back button.
  final bool showBackButton;

  /// The footer.
  final Widget? footer;

  /// Creates a new page scaffold instance.
  const PageScaffold({
    super.key,
    required this.pages,
    this.showBackButton = false,
    this.footer,
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

  /// Whether to display the floating action button.
  bool showFloatingActionButton = true;

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
    PageWidget page = widget.pages[currentPageIndex];
    Widget body = widget.pages.length == 1
        ? widget.pages.first
        : TabBarView(
            controller: tabController,
            children: widget.pages,
          );
    return FScaffold(
      header: FHeader.nested(
        title: Text(page.title),
        style: (style) => style.copyWith(
          titleTextStyle: style.titleTextStyle.copyWith(
            fontFamily: 'BirdsOfParadise',
          ),
        ),
        prefixes: page.prefixes,
        suffixes: page.suffixes,
      ),
      // TODO
      // floatingActionButton: _FloatingActionButton(),
      // floatingActionButtonLocation: widget.pages.length > 1 ? FloatingActionButtonLocation.centerDocked : FloatingActionButtonLocation.centerFloat,
      footer: widget.pages.length > 1
          ? _BottomNavigationBar(
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
      child: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          ScrollDirection direction = notification.direction;
          if (direction == ScrollDirection.reverse) {
            setState(() => showFloatingActionButton = false);
          } else if (direction == ScrollDirection.forward) {
            setState(() => showFloatingActionButton = true);
          }
          return true;
        },
        child: Stack(
          children: [
            body,
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 200),
                offset: showFloatingActionButton ? Offset.zero : Offset(0, 2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: showFloatingActionButton ? 1 : 0,
                  child: FButton.icon(
                    style: context.theme.buttonStyles.primary.call,
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: ScalableImageWidget.fromSISource(
                        si: ScalableImageSource.fromSvg(rootBundle, 'assets/images/add.svg'),
                      ),
                    ),
                    onPress: () {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }
}

/// The app floating action button.
// class _FloatingActionButton extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) => FloatingActionButton(
//         elevation: 0,
//         focusElevation: 0,
//         hoverElevation: 0,
//         highlightElevation: 0,
//         heroTag: currentPlatform.isDesktop ? null : runtimeType.toString(),
//         backgroundColor: Theme.of(context).colorScheme.darkPrimary,
//         onPressed: () {
//           BeerRepository repository = ref.read(beerRepositoryProvider);
//           if (repository.isEmpty) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//               content: Text(translations.error.addBeerFirst),
//               backgroundColor: Theme.of(context).colorScheme.error,
//             ));
//             return;
//           }
//           HistoryEntryEditorDialog.newEntry(
//             context: context,
//             beer: repository.objects.first,
//           );
//         },
//         child: ScalableImageWidget.fromSISource(
//           si: ScalableImageSource.fromSvg(rootBundle, 'assets/images/add.svg'),
//         ),
//       );
// }

/// The app bottom bar, displayed when there is more than one page to show.
class _BottomNavigationBar extends StatelessWidget {
  /// The pages.
  final List<PageWidget> pages;

  /// The current page index.
  final int currentPageIndex;

  /// Triggered when a new page has been selected.
  final Function(int pageIndex) onPageSelected;

  /// Creates a new bottom app bar instance.
  const _BottomNavigationBar({
    required this.pages,
    required this.currentPageIndex,
    required this.onPageSelected,
  }) : assert(pages.length >= 2);

  @override
  Widget build(BuildContext context) => FBottomNavigationBar(
        index: currentPageIndex,
        onChange: onPageSelected,
        // TODO: background gradient
        children: [
          for (int i = 0; i < pages.length; i++)
            FBottomNavigationBarItem(
              icon: Icon(pages[i].icon),
              label: Text(pages[i].title),
            ),
        ],
      );
}
