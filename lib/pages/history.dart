import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/history_entry/repository.dart';
import 'package:beerstory/pages/body.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/widgets/async_value_widget.dart';
import 'package:beerstory/widgets/empty.dart';
import 'package:beerstory/widgets/ordered_list_view.dart';
import 'package:beerstory/widgets/repository/history_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The history scaffold body widget.
class HistoryScaffoldBody extends ScaffoldBodyWidget<HistoryEntry> {
  /// Creates a new history scaffold body widget instance.
  const HistoryScaffoldBody({
    super.key,
  }) : super(
         reverseOrder: true,
       );

  @override
  AsyncNotifierProvider<History, List<HistoryEntry>> get repositoryProvider => historyProvider;

  @override
  Widget buildBodyWidget(
    BuildContext context,
    WidgetRef ref,
    List<HistoryEntry> entries,
  ) => AsyncValueWidget(
    provider: beerRepositoryProvider,
    builder: (context, ref, beers) {
      Map<String, Beer> beersList = {
        for (Beer beer in beers) beer.uuid: beer,
      };
      return LayoutBuilder(
        builder: (context, constraints) => OrderedListView<HistoryEntry>(
          objects: entries,
          builder: (object) => HistoryEntryWidget(
            historyEntry: object,
          ),
          reverseOrder: reverseOrder,
          groupObjects: (entries) {
            Map<DateTime, _DateGroupData> groupedEntries = {};
            for (HistoryEntry entry in entries) {
              DateTime date = entry.date;
              if (groupedEntries.containsKey(date)) {
                groupedEntries[date]!.add(entry);
              } else {
                groupedEntries[date] = _DateGroupData(entry: entry);
              }
            }
            return groupedEntries.values.toList()..sort();
          },
          comparator: (a, b) {
            Beer? aBeer = beersList[a.beerUuid];
            Beer? bBeer = beersList[b.beerUuid];
            if (aBeer != null && bBeer != null) {
              int beerComparison = aBeer.compareTo(bBeer);
              if (beerComparison != 0) {
                return beerComparison;
              }
            }
            return a.compareTo(b);
          },
          emptyWidgetBuilder: (context, search) => Container(
            padding: const EdgeInsets.all(kSpace),
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: EmptyWidget(
                text: translations.history.page.empty,
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// A group data that contains a [date].
class _DateGroupData extends GroupData<HistoryEntry> {
  /// The date.
  final DateTime date;

  /// The absorb result instance.
  final AbsorbResult result;

  /// Creates a new date group data instance.
  _DateGroupData({
    required HistoryEntry entry,
  }) : date = entry.date,
       result = AbsorbResult.fromHistoryEntry(historyEntry: entry),
       super(
         objects: [entry],
       );

  /// Adds the specified entry to this group.
  void add(HistoryEntry entry) {
    objects.add(entry);
    result.absorb(entry);
  }

  @override
  TextSpan get label => TextSpan(
    text: DateFormat.yMMMMd(
      LocaleSettings.currentLocale.languageCode,
    ).format(date),
  );

  @override
  TextSpan? get description => result.quantity == null
      ? null
      : TextSpan(
          children: [
            TextSpan(
              text: translations.history.page.total,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: translations.history.page.quantity(
                prefix: result.moreThanQuantity ? '+' : '',
                quantity: NumberFormat.decimalPattern().format(result.quantity),
              ),
            ),
          ],
        );

  @override
  bool operator ==(Object other) {
    if (other is! _DateGroupData) {
      return super == other;
    }
    return identical(this, other) || date == other.date;
  }

  @override
  int get hashCode => date.hashCode;

  @override
  int compareTo(GroupData other) {
    if (other is _DateGroupData) {
      return other.date.compareTo(date);
    }
    return super.compareTo(other);
  }
}
