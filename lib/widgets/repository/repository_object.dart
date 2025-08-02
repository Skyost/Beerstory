import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/adaptive_actions_wrapper.dart';
import 'package:beerstory/widgets/async_value_widget.dart';
import 'package:beerstory/widgets/scrollable_sheet_content.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// A repository object widget.
abstract class RepositoryObjectWidget<T extends RepositoryObject> extends ConsumerWidget with FTileMixin {
  /// The object.
  final T object;

  /// Creates a new app widget instance.
  const RepositoryObjectWidget({
    super.key,
    required this.object,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => FTile(
    prefix: buildPrefix(context),
    suffix: buildSuffix(context),
    title: buildTitle(context),
    subtitle: buildSubtitle(context),
    onPress: () => showFSheet(
      context: context,
      builder: (context) => ScrollableSheetContentWidget(
        builder: buildDetailsWidget,
      ),
      side: FLayout.btt,
      mainAxisMaxRatio: null,
    ),
  );

  /// Builds the prefix widget.
  Widget? buildPrefix(BuildContext context) => null;

  /// Builds the suffix widget.
  Widget? buildSuffix(BuildContext context) => null;

  /// Builds the widget title.
  Widget buildTitle(BuildContext context) => const SizedBox.shrink();

  /// Builds the widget subtitle.
  Widget? buildSubtitle(BuildContext context) => null;

  /// Allows to show more details about the [object].
  Widget buildDetailsWidget(BuildContext context, ScrollController scrollController);
}

/// The base class for repository object details widgets.
abstract class DetailsWidget<T extends RepositoryObject, S> extends ConsumerWidget {
  /// Creates a new repository object details widget instance.
  const DetailsWidget({
    super.key,
  });

  /// The corresponding repository provider.
  AsyncNotifierProvider<Repository<T>, List<T>> get repositoryProvider;

  /// The corresponding object provider.
  ProviderListenable<AsyncValue<S?>> get objectProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueWidget(
    provider: objectProvider,
    builder: (context, ref, object) => buildChild(context, ref, object as S),
  );

  /// Builds the child for the [object].
  Widget buildChild(BuildContext context, WidgetRef ref, S object);

  /// Adds a given [object] and shows a waiting overlay.
  Future<void> addObject(BuildContext context, WidgetRef ref, T object) async {
    try {
      await showWaitingOverlay(
        context,
        future: ref.read(repositoryProvider.notifier).add(object),
      );
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

  /// Edits a given [object] and shows a waiting overlay.
  Future<void> editObject(BuildContext context, WidgetRef ref, T object) async {
    try {
      await showWaitingOverlay(
        context,
        future: ref.read(repositoryProvider.notifier).change(object),
      );
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

  /// Deletes a given [object] and shows a waiting overlay.
  Future<void> deleteObject(BuildContext context, WidgetRef ref, T object) async {
    try {
      await showWaitingOverlay(
        context,
        future: ref.read(repositoryProvider.notifier).remove(object),
      );
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
}

/// The base class for repository object details widgets.
abstract class RepositoryObjectDetailsWidget<T extends RepositoryObject> extends DetailsWidget<T, T?> {
  /// The object UUID.
  final String objectUuid;

  /// The scroll controller.
  final ScrollController? scrollController;

  /// Creates a new repository object details widget instance.
  const RepositoryObjectDetailsWidget({
    super.key,
    required this.objectUuid,
    this.scrollController,
  });

  @override
  ProviderListenable<AsyncValue<T?>> get objectProvider => repositoryProvider.select(
    (value) => value.map<AsyncValue<T?>>(
      data: (data) => AsyncData(data.value.findByUuid(objectUuid)),
      loading: (loading) => const AsyncLoading(),
      error: (error) => AsyncError(error.error, error.stackTrace),
    ),
  );

  @override
  Widget buildChild(BuildContext context, WidgetRef ref, T? object) {
    List<Widget> children = buildChildren(context, ref, object!);
    return ListView(
      controller: scrollController,
      children: [
        for (int i = 0; i < children.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i < children.length - 1 ? kSpace : kSpace * 2,
            ),
            child: children[i],
          ),
        AdaptiveActionsWrapper(
          actions: buildActions(context, ref, object),
        ),
      ],
    );
  }

  /// Builds the children for the [object].
  List<Widget> buildChildren(BuildContext context, WidgetRef ref, T object);

  /// Builds the actions for the [object].
  List<FButton> buildActions(BuildContext context, WidgetRef ref, T object) => [
    FButton(
      style: FButtonStyle.destructive(),
      child: Text(translations.misc.delete),
      onPress: () async {
        if (await showDeleteConfirmationDialog(context) && context.mounted) {
          await deleteObject(context, ref, object);
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
    ),
  ];

  /// The delete confirmation message.
  String get deleteConfirmationMessage;

  /// Shows a delete confirmation dialog.
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async =>
      (await showFDialog(
        context: context,
        builder: (context, style, animation) => FDialog.adaptive(
          body: Text(deleteConfirmationMessage),
          actions: [
            FButton(
              style: FButtonStyle.outline(),
              child: Text(translations.misc.cancel),
              onPress: () => Navigator.pop(context, false),
            ),
            FButton(
              style: FButtonStyle.destructive(),
              child: Text(translations.misc.yes),
              onPress: () => Navigator.pop(context, true),
            ),
          ],
        ),
      )) ==
      true;
}
