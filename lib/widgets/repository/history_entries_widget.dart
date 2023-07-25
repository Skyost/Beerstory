import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history/entries.dart';
import 'package:beerstory/model/history/entry.dart';
import 'package:beerstory/model/history/history.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/editors/beer_editor_dialog.dart';
import 'package:beerstory/widgets/editors/history_entry_editor_dialog.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:beerstory/widgets/repository/repository_object.dart';
import 'package:beerstory/widgets/tag.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// A widget that allows to display history entries.
class HistoryEntriesWidget extends StatelessWidget {
  /// The corresponding entries.
  final HistoryEntries entries;

  /// Creates a new history entries widget.
  const HistoryEntriesWidget({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).colorScheme.darkPrimary,
            padding: const EdgeInsets.all(10),
            child: Text(
              DateFormat.yMMMMd(EzLocalization.of(context)?.locale.languageCode).format(entries.date),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          for (int index = 0; index < entries.count; index++)
            HistoryEntryWidget(
              date: entries.date,
              historyEntry: entries[index],
              backgroundColor: index % 2 == 1 ? Colors.black.withOpacity(0.03) : null,
            ),
        ],
      );
}

/// A widget that allows to display a history entry.
class HistoryEntryWidget extends RepositoryObjectWidget {
  /// The date.
  final DateTime date;

  /// The history entry.
  final HistoryEntry historyEntry;

  /// Creates a new history entry widget.
  const HistoryEntryWidget({
    super.key,
    required this.date,
    required this.historyEntry,
    super.backgroundColor,
  });

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    BeerRepository beerRepository = ref.watch(beerRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: TagWidget(
                text: '${historyEntry.times}x',
              ),
            ),
            Flexible(
              child: BeerWidget(
                beer: beerRepository.findByUuid(historyEntry.beerUuid)!,
                padding: null,
                addClickListeners: false,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text.rich(TextSpan(
            children: [
              TextSpan(
                text: context.getString('page.history.total').toUpperCase(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: context.getString('page.history.quantity', {
                  'prefix': historyEntry.moreThanQuantity ? '+' : '',
                  'quantity': NumberFormat.decimalPattern().format(historyEntry.quantity ?? 0),
                }),
              ),
            ],
          )),
        )
      ],
    );
  }

  @override
  void onTap(BuildContext context, WidgetRef ref) => BeerEditorDialog.show(
        context: context,
        beer: ref.read(beerRepositoryProvider).findByUuid(historyEntry.beerUuid)!,
        readOnly: true,
      );

  @override
  void onEdit(BuildContext context, WidgetRef ref) => HistoryEntryEditorDialog.show(
        context: context,
        date: date,
        historyEntry: historyEntry,
      );

  @override
  void onDelete(BuildContext context, WidgetRef ref) => ref.read(historyProvider).removeEntry(date, historyEntry);
}
