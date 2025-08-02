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
import 'package:beerstory/pages/settings.dart';
import 'package:beerstory/utils/platform.dart';
import 'package:beerstory/utils/scan_beer.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/beer_animation_dialog.dart';
import 'package:beerstory/widgets/blur.dart';
import 'package:beerstory/widgets/editors/bar_edit.dart';
import 'package:beerstory/widgets/editors/beer_edit.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:beerstory/widgets/editors/history_entry_edit.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/foundation.dart';
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
class _HomeRouteScaffoldState extends ConsumerState<HomeRouteScaffold> with SingleTickerProviderStateMixin<HomeRouteScaffold> {
  /// The current index.
  int currentPageIndex = 0;

  /// The current menu index.
  int currentMenuIndex = 0;

  /// The tab controller.
  late TabController tabController =
      TabController(
        vsync: this,
        length: 2,
        initialIndex: currentPageIndex,
      )..addListener(() {
        if (mounted) {
          setState(() {
            currentPageIndex = tabController.index;
            if (!tabController.indexIsChanging) {
              if (tabController.previousIndex == 0 && tabController.index == 1) {
                currentMenuIndex = 2;
              } else if (tabController.previousIndex == 1 && tabController.index == 0) {
                currentMenuIndex = 0;
              }
            }
          });
        }
      });

  /// Whether the currently displayed page is the beers body widget.
  bool get areBeersDisplayed => currentPageIndex == 0;

  /// Returns the current page title.
  String get pageTitle => areBeersDisplayed ? translations.beers.page.name : translations.bars.page.name;

  /// Returns the suffixes corresponding to the current body widget.
  List<Widget> get suffixes => areBeersDisplayed
      ? [
          const _AddBeerButton(),
        ]
      : [
          _AddObjectWidget(
            showEditor: (context) => AddBarDialog.show(context: context),
            repositoryProvider: barRepositoryProvider,
            addedString: translations.bars.dialog.added,
            builder: (onPress) => FHeaderAction(
              icon: const Icon(FIcons.ellipsis),
              onPress: onPress,
            ),
          ),
        ];

  @override
  Widget build(BuildContext context) {
    int historyLength = ref.watch(historyProvider.select((history) => history.value?.length ?? 0));
    int beerCount = ref.watch(beerRepositoryProvider.select((beers) => beers.value?.length ?? 0));

    return FScaffold(
      header: FHeader.nested(
        title: GestureDetector(
          child: Text(pageTitle),
          onTap: () => Navigator.pushNamed(context, kSettingsRoute),
        ),
        prefixes: [if (historyLength > 0) _HistoryButton()],
        suffixes: suffixes,
      ),
      footer: FBottomNavigationBar(
        index: currentMenuIndex,
        onChange: (pageIndex) {
          if (pageIndex == 1) {
            return;
          }
          setState(() => currentMenuIndex = pageIndex);
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
          if (beerCount > 0) _NewHistoryEntryButton() else const SizedBox.shrink(),
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
    super.dispose();
  }
}

/// Allows to insert a new history entry.
class _NewHistoryEntryButton extends ConsumerStatefulWidget {
  /// The size of the button.
  final double size;

  /// Creates a new new history entry button instance.
  const _NewHistoryEntryButton({
    this.size = 56,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewHistoryEntryButtonState();
}

class _NewHistoryEntryButtonState extends ConsumerState<_NewHistoryEntryButton> with SingleTickerProviderStateMixin<_NewHistoryEntryButton> {
  /// The gradient animation controller.
  late AnimationController gradientAnimationController =
      AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      )..addListener(() {
        setState(() => {});
      });

  /// Returns the blur value.
  double get blur => lerpDouble(0, 4, gradientAnimationController.value)!;

  /// Returns the color opacity.
  double get colorOpacity => lerpDouble(0, 0.3, gradientAnimationController.value)!;

  /// Called when the gradient should change.
  void onGradientShouldChange(bool hovered) {
    if (hovered) {
      gradientAnimationController.animateTo(1, curve: Curves.easeIn);
    } else {
      gradientAnimationController.animateTo(0, curve: Curves.easeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Beer>? beers = ref.watch(beerRepositoryProvider).value;
    return beers == null || beers.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            height: widget.size,
            child: BlurWidget(
              below: Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: lerpDouble(0.55, 0.4, gradientAnimationController.value)!,
                      colors: [
                        context.theme.colors.primary.withValues(
                          alpha: lerpDouble(0.3, 1, gradientAnimationController.value),
                        ),
                        (context.theme.bottomNavigationBarStyle.decoration.color ?? context.theme.colors.background).withValues(
                          alpha: lerpDouble(0.7, 0.5, gradientAnimationController.value),
                        ),
                      ],
                      stops: [lerpDouble(0, 0.75, gradientAnimationController.value)!, 1.0],
                    ),
                  ),
                ),
              ),
              blur: blur,
              colorOpacity: colorOpacity,
              child: FTappable(
                onHoverChange: onGradientShouldChange,
                onPress: () async {
                  if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
                    onGradientShouldChange.call(true);
                  }
                  Beer? beer;
                  String? lastBeerUuid = ref.read(lastInsertedBeerProvider);
                  if (lastBeerUuid != null) {
                    beer = beers.findByUuid(lastBeerUuid);
                  }
                  beer ??= beers.first;
                  FormDialogResult<HistoryEntry> historyEntry = await AddHistoryEntryDialog.show(
                    context: context,
                    historyEntry: HistoryEntry(beerUuid: beer.uuid),
                  );
                  if (historyEntry is FormDialogResultSaved<HistoryEntry> && context.mounted) {
                    Future addFuture = ref.read(historyProvider.notifier).absorb(historyEntry.value);
                    await BeerAnimationDialog.show(
                      context: context,
                      onFinished: () async {
                        try {
                          await addFuture;
                        } catch (ex, stackTrace) {
                          printError(ex, stackTrace);
                          if (context.mounted) {
                            showFToast(
                              context: context,
                              title: Text(translations.error.generic),
                              style: (style) => style.copyWith(
                                titleTextStyle: style.titleTextStyle.copyWith(
                                  color: context.theme.colors.error,
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
                  if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
                    onGradientShouldChange.call(false);
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

  @override
  void dispose() {
    gradientAnimationController.dispose();
    super.dispose();
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
class _AddBeerButton extends ConsumerWidget {
  /// Creates a new add beer button instance.
  const _AddBeerButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) => currentPlatform.isMobile
      ? FPopoverMenu(
          menuAnchor: Alignment.topRight,
          childAnchor: Alignment.bottomRight,
          menu: [
            FItemGroup(
              children: [
                FItem(
                  prefix: const Icon(FIcons.barcode),
                  title: Text(translations.beers.page.menu.addFromScan),
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
                ),
                _AddObjectWidget(
                  showEditor: (context) => AddBeerDialog.show(context: context),
                  repositoryProvider: beerRepositoryProvider,
                  addedString: translations.beers.dialog.added,
                  builder: (onPress) => FItem(
                    prefix: const Icon(FIcons.textCursor),
                    title: Text(translations.beers.page.menu.manualAdd),
                    onPress: onPress,
                  ),
                ),
              ],
            ),
          ],
          builder: (context, controller, child) => FHeaderAction(
            icon: const Icon(FIcons.ellipsis),
            onPress: controller.toggle,
          ),
        )
      : _AddObjectWidget(
          showEditor: (context) => AddBeerDialog.show(context: context),
          repositoryProvider: beerRepositoryProvider,
          addedString: translations.beers.dialog.added,
          builder: (onPress) => FHeaderAction(
            icon: const Icon(FIcons.plus),
            onPress: onPress,
          ),
        );
}

/// The add object widget.
class _AddObjectWidget<T extends RepositoryObject> extends ConsumerWidget with FItemMixin {
  /// The show editor function.
  final Future<FormDialogResult<T>> Function(BuildContext) showEditor;

  /// The repository provider.
  final AsyncNotifierProvider<Repository<T>, List<T>> repositoryProvider;

  /// The string displayed when the object is added.
  final String addedString;

  /// The widget builder.
  final Function(VoidCallback) builder;

  /// Creates a new add beer button instance.
  const _AddObjectWidget({
    required this.showEditor,
    required this.repositoryProvider,
    required this.addedString,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => builder(
    () async {
      FormDialogResult<T?> object = await showEditor(context);
      if (object is FormDialogResultSaved<T> && context.mounted) {
        try {
          await showWaitingOverlay(
            context,
            future: ref.read(repositoryProvider.notifier).add(object.value),
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
                  color: context.theme.colors.error,
                ),
              ),
            );
          }
        }
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

/// The settings route scaffold.
class SettingsRouteScaffold extends StatelessWidget {
  /// Creates a new settings route scaffold instance.
  const SettingsRouteScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) => FScaffold(
    header: FHeader.nested(
      title: Text(translations.settings.page.name),
      prefixes: [
        FHeaderAction.x(
          onPress: () => Navigator.pop(context),
        ),
      ],
    ),
    child: const SettingsScaffoldBody(),
  );
}
