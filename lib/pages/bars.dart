import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/pages/page.dart';
import 'package:beerstory/widgets/editors/bar_editor_dialog.dart';
import 'package:beerstory/widgets/history_button.dart';
import 'package:beerstory/widgets/repository/bar.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bars page.
class BarsPage extends Page<Bar> {
  /// Creates a new bars page instance.
  const BarsPage({
    super.key,
  }) : super(
          icon: Icons.local_bar,
          titleKey: 'page.bars.name',
          emptyMessageKey: 'page.bars.empty',
          actions: const [
            _AddBarButton(),
            HistoryButton(),
          ],
        );

  @override
  Widget createObjectWidget(Bar object, int position) => BarWidget(
        bar: object,
        backgroundColor: position % 2 == 0 ? Colors.black.withOpacity(0.03) : null,
      );

  @override
  BarRepository watchRepository(WidgetRef ref) => ref.watch(barRepositoryProvider);
}

/// The add bar button.
class _AddBarButton extends StatelessWidget {
  /// Creates a new add bar button instance.
  const _AddBarButton();

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => BarEditorDialog.show(context: context),
      );
}
