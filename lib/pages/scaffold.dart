import 'dart:async';
import 'dart:ui';

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/history_entry/repository.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/pages/bars.dart';
import 'package:beerstory/pages/beers.dart';
import 'package:beerstory/pages/history.dart';
import 'package:beerstory/pages/routes.dart';
import 'package:beerstory/utils/scan_beer.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/beer_animation_dialog.dart';
import 'package:beerstory/widgets/blur.dart';
import 'package:beerstory/widgets/editors/bar_edit.dart';
import 'package:beerstory/widgets/editors/beer_edit.dart';
import 'package:beerstory/widgets/editors/history_entry_edit.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:jovial_svg/jovial_svg.dart';

/// The main route scaffold.
class HomeRouteScaffold extends ConsumerStatefulWidget {
  /// Creates a new main route scaffold instance.
  const HomeRouteScaffold({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeRouteScaffoldState();
}

/// The main route scaffold state.
class _HomeRouteScaffoldState extends ConsumerState<HomeRouteScaffold> with TickerProviderStateMixin<HomeRouteScaffold> {
  /// The current index.
  int currentPageIndex = 0;

  /// The tab controller.
  late TabController tabController =
      TabController(
        vsync: this,
        length: 2,
        initialIndex: currentPageIndex,
      )..addListener(() {
        if (mounted) {
          setState(() => currentPageIndex = tabController.index);
        }
      });

  /// The gradient animation controller.
  late AnimationController gradientAnimationController =
      AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      )..addListener(() {
        setState(() => {});
      });

  /// Whether the currently displayed page is the beers body widget.
  bool get areBeersDisplayed => currentPageIndex == 0;

  /// Returns the current page title.
  String get pageTitle => areBeersDisplayed ? translations.beers.page.name : translations.bars.page.name;

  /// Returns the suffixes corresponding to the current body widget.
  List<Widget> get suffixes => areBeersDisplayed
      ? [
          const _ScanBeerButton(),
          _AddButton(
            showEditor: (context) => AddBeerDialog.show(context: context),
            repositoryProvider: beerRepositoryProvider,
            addedString: translations.beers.dialog.added,
          ),
        ]
      : [
          _AddButton(
            showEditor: (context) => AddBarDialog.show(context: context),
            repositoryProvider: barRepositoryProvider,
            addedString: translations.bars.dialog.added,
          ),
        ];

  @override
  Widget build(BuildContext context) {
    int historyLength = ref.watch(historyProvider.select((history) => history.value?.length ?? 0));
    int beerCount = ref.watch(beerRepositoryProvider.select((beers) => beers.value?.length ?? 0));

    return FScaffold(
      header: FHeader.nested(
        title: Text(pageTitle),
        prefixes: [if (historyLength > 0) _HistoryButton()],
        suffixes: suffixes,
      ),
      footer: FBottomNavigationBar(
        style: beerCount > 0
            ? (style) => style.copyWith(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: lerpDouble(0.6, 0.4, gradientAnimationController.value)!,
                    colors: [
                      context.theme.colors.primary.withValues(
                        alpha: lerpDouble(0.3, 1, gradientAnimationController.value),
                      ),
                      (style.decoration.color ?? context.theme.colors.background).withValues(
                        alpha: lerpDouble(0.7, 0.5, gradientAnimationController.value),
                      ),
                    ],
                    stops: [lerpDouble(0, 0.75, gradientAnimationController.value)!, 1.0],
                  ),
                ),
              )
            : null,
        index: currentPageIndex,
        onChange: (pageIndex) {
          if (pageIndex == 1) {
            return;
          }
          if (pageIndex == 2) {
            pageIndex = 1;
          }
          if (pageIndex != currentPageIndex) {
            currentPageIndex = pageIndex;
            tabController.animateTo(currentPageIndex);
          }
        },
        children: [
          FBottomNavigationBarItem(
            icon: const Icon(FIcons.beer),
            label: Text(translations.beers.page.name),
          ),
          if (beerCount > 0)
            _NewHistoryEntryButton(
              blur: lerpDouble(0, 4, gradientAnimationController.value)!,
              colorOpacity: lerpDouble(0, 0.3, gradientAnimationController.value)!,
              onHoverChange: (hovered) {
                if (hovered) {
                  gradientAnimationController.animateTo(
                    1,
                    curve: Curves.easeIn,
                  );
                } else {
                  gradientAnimationController.animateTo(
                    0,
                    curve: Curves.easeIn,
                  );
                }
              },
            )
          else
            const SizedBox.shrink(),
          FBottomNavigationBarItem(
            icon: const Icon(FIcons.mapPin),
            label: Text(translations.bars.page.name),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      child: TabBarView(
        controller: tabController,
        children: [
          const BeersScaffoldBody(),
          const BarsScaffoldBody(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    gradientAnimationController.dispose();
    super.dispose();
  }
}

/// Allows to insert a new history entry.
class _NewHistoryEntryButton extends ConsumerWidget {
  /// The size of the button.
  final double size;

  /// The blur of the button background.
  final double blur;

  /// The opacity of the button background.
  final double colorOpacity;

  /// Handler called when the hover changes.
  final ValueChanged<bool>? onHoverChange;

  /// Creates a new new history entry button instance.
  const _NewHistoryEntryButton({
    this.size = 56,
    this.blur = 0,
    this.colorOpacity = 0,
    this.onHoverChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Beer>? beers = ref.watch(beerRepositoryProvider).value;
    return beers == null || beers.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            width: size,
            height: size,
            child: BlurWidget(
              blur: blur,
              colorOpacity: colorOpacity,
              child: FTappable(
                onHoverChange: onHoverChange,
                onPress: () async {
                  Beer? beer;
                  String? lastBeerUuid = ref.read(lastInsertedBeerProvider);
                  if (lastBeerUuid != null) {
                    beer = beers.findByUuid(lastBeerUuid);
                  }
                  beer ??= beers.first;
                  HistoryEntry? historyEntry = await AddHistoryEntryDialog.show(
                    context: context,
                    historyEntry: HistoryEntry(beerUuid: beer.uuid),
                  );
                  if (historyEntry != null && context.mounted) {
                    Completer addCompleter = Completer();
                    ref.read(historyProvider.notifier).add(historyEntry).then(addCompleter.complete).catchError(addCompleter.completeError);
                    await BeerAnimationDialog.show(
                      context: context,
                      onFinished: () async {
                        try {
                          await addCompleter.future;
                        } catch (ex, stackTrace) {
                          printError(ex, stackTrace);
                          if (context.mounted) {
                            showFToast(
                              context: context,
                              title: Text(translations.error.generic),
                              style: (style) => style.copyWith(
                                titleTextStyle: style.titleTextStyle.copyWith(
                                  color: context.theme.colors.errorForeground,
                                ),
                              ),
                            );
                          }
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    );
                  }
                },
                child: ScalableImageWidget.fromSISource(
                  si: ScalableImageSource.fromSI(
                    rootBundle,
                    'assets/images/add.si',
                  ),
                ),
              ),
            ),
          );
  }
}

/// The history route scaffold.
class HistoryRouteScaffold extends StatelessWidget {
  /// Creates a new history route scaffold instance.
  const HistoryRouteScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) => FScaffold(
    header: FHeader.nested(
      title: Text(translations.history.page.name),
      prefixes: [
        FHeaderAction.x(
          onPress: () => Navigator.pop(context),
        ),
      ],
      suffixes: [
        const _ClearHistoryButton(),
      ],
    ),
    child: const HistoryScaffoldBody(),
  );
}

/// A simple history button.
class _HistoryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FHeaderAction(
    icon: const Icon(FIcons.history),
    onPress: () => Navigator.pushNamed(context, kHistoryRoute),
  );
}

/// The add beer button.
class _AddButton<T extends RepositoryObject> extends ConsumerWidget {
  /// The show editor function.
  final Future<T?> Function(BuildContext) showEditor;

  /// The repository provider.
  final AsyncNotifierProvider<Repository<T>, List<T>> repositoryProvider;

  /// The string displayed when the object is added.
  final String addedString;

  /// Creates a new add beer button instance.
  const _AddButton({
    required this.showEditor,
    required this.repositoryProvider,
    required this.addedString,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => FHeaderAction(
    icon: const Icon(FIcons.plus),
    onPress: () async {
      T? object = await showEditor(context);
      if (object != null && context.mounted) {
        try {
          await showWaitingOverlay(
            context,
            future: ref.read(repositoryProvider.notifier).add(object),
          );
          if (context.mounted) {
            showFToast(
              context: context,
              title: Text(addedString),
            );
          }
        } catch (ex, stackTrace) {
          printError(ex, stackTrace);
          if (context.mounted) {
            showFToast(
              context: context,
              title: Text(translations.error.generic),
              style: (style) => style.copyWith(
                titleTextStyle: style.titleTextStyle.copyWith(
                  color: context.theme.colors.errorForeground,
                ),
              ),
            );
          }
        }
      }
    },
  );
}

/// The scan beer button.
class _ScanBeerButton extends ConsumerWidget {
  /// Creates a new scan beer button instance.
  const _ScanBeerButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) => FHeaderAction(
    icon: const Icon(FIcons.barcode),
    onPress: () async {
      ScanResult result = await scanBeer(context);
      if (context.mounted) {
        context.handleScanResult(
          result,
          onSuccess: (beer) async {
            await showWaitingOverlay(
              context,
              future: ref.read(beerRepositoryProvider.notifier).add(beer),
            );
          },
        );
      }
    },
  );
}

/// The clear history button.
class _ClearHistoryButton extends ConsumerWidget {
  /// Creates a new clear history button instance.
  const _ClearHistoryButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) => FHeaderAction(
    icon: const Icon(FIcons.brushCleaning),
    onPress: () => showFDialog(
      context: context,
      builder: (context, style, animation) => FDialog.adaptive(
        style: style.call,
        animation: animation,
        body: Text(translations.history.page.clearConfirm),
        actions: [
          FButton(
            style: FButtonStyle.outline(),
            onPress: () => Navigator.pop(context),
            child: Text(translations.misc.no),
          ),
          FButton(
            onPress: () async {
              await showWaitingOverlay(
                context,
                future: ref.read(historyProvider.notifier).clear(),
              );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(translations.misc.yes),
          ),
        ],
      ),
    ),
  );
}
