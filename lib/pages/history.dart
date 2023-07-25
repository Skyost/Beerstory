import 'package:beerstory/model/history/entries.dart';
import 'package:beerstory/model/history/history.dart';
import 'package:beerstory/pages/page.dart';
import 'package:beerstory/widgets/repository/history_entries_widget.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The history page.
class HistoryPage extends Page<HistoryEntries> {
  /// Creates a new history page instance.
  const HistoryPage({
    super.key,
  }) : super(
          icon: Icons.history,
          titleKey: 'page.history.name',
          emptyMessageKey: 'page.history.empty',
          actions: const [
            _ClearHistoryButton(),
          ],
          searchBox: false,
          reverseOrder: true,
        );

  @override
  Widget createObjectWidget(HistoryEntries object, int position) => HistoryEntriesWidget(
        entries: object,
      );

  @override
  History watchRepository(WidgetRef ref) => ref.watch(historyProvider);
}

/// The clear history button.
class _ClearHistoryButton extends ConsumerWidget {
  /// Creates a new clear history button instance.
  const _ClearHistoryButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(context.getString('page.history.clearConfirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel.toUpperCase()),
              ),
              TextButton(
                onPressed: () {
                  ref.read(historyProvider)
                    ..clear()
                    ..save();
                  Navigator.pop(context);
                },
                child: Text(MaterialLocalizations.of(context).okButtonLabel.toUpperCase()),
              ),
            ],
          ),
        ),
      );
}
