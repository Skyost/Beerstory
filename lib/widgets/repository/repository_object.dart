import 'package:beerstory/model/repository.dart';
import 'package:beerstory/widgets/scrollable_sheet_content.dart';
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
