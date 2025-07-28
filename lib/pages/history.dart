import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/history_entry/repository.dart';
import 'package:beerstory/pages/page.dart';
import 'package:beerstory/widgets/repository/history_entry.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// The history page.
class HistoryPage extends PageWidget<HistoryEntry, History> {
  /// The history page.
  static const String page = '/history';

  /// Creates a new history page instance.
  HistoryPage({
    super.key,
  }) : super(
          icon: FIcons.history,
          title: translations.history.page.name,
          emptyMessage: translations.history.page.empty,
          prefixes: const [
            _ClosePageButton(),
          ],
          suffixes: const [
            _ClearHistoryButton(),
          ],
          reverseOrder: true,
        );

  @override
  AsyncNotifierProvider<History, List<HistoryEntry>> get repositoryProvider => historyProvider;

  @override
  Widget createObjectWidget(HistoryEntry object, int position) => HistoryEntryWidget(
        historyEntry: object,
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

/// The close page button.
class _ClosePageButton extends StatelessWidget {
  /// Creates a new close page button instance.
  const _ClosePageButton();

  @override
  Widget build(BuildContext context) => FHeaderAction.x(
        onPress: () => Navigator.pop(context),
      );
}
