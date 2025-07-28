import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/pages/page.dart';
import 'package:beerstory/widgets/editors/bar_editor_dialog.dart';
import 'package:beerstory/widgets/repository/bar.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// The bars page.
class BarsPage extends PageWidget<Bar, BarRepository> {
  /// Creates a new bars page instance.
  BarsPage({
    super.key,
  }) : super(
          icon: FIcons.beer,
          title: translations.bars.page.name,
          emptyMessage: translations.bars.page.empty,
          prefixes: const [
            HistoryButton(),
          ],
          suffixes: const [
            _AddBarButton(),
          ],
        );

  @override
  Widget createObjectWidget(Bar object, int position) => BarWidget(
        object: object,
      );

  @override
  AsyncNotifierProvider<BarRepository, List<Bar>> get repositoryProvider => barRepositoryProvider;
}

/// The add bar button.
class _AddBarButton extends ConsumerWidget {
  /// Creates a new add bar button instance.
  const _AddBarButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) => FHeaderAction(
        icon: Icon(FIcons.plus),
        onPress: () async {
          Bar? bar = await BarEditorDialog.show(context: context);
          if (bar != null && context.mounted) {
            showWaitingOverlay(
              context,
              future: ref.read(barRepositoryProvider.notifier).add(bar),
            );
          }
        },
      );
}
