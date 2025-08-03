import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/history_entry/repository.dart';
import 'package:beerstory/pages/body.dart';
import 'package:beerstory/utils/format.dart';
import 'package:beerstory/widgets/async_value_widget.dart';
import 'package:beerstory/widgets/ordered_list_view.dart';
import 'package:beerstory/widgets/repository/history_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

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
  Widget buildBodyWidget(BuildContext context, WidgetRef ref, List<HistoryEntry> entries, {Comparator<HistoryEntry>? comparator}) => AsyncValueWidget(
    provider: beerRepositoryProvider,
    builder: (context, ref, beers) {
      Map<String, Beer> beersList = {
        for (Beer beer in beers) beer.uuid: beer,
      };
      comparator ??= (a, b) {
        Beer? aBeer = beersList[a.beerUuid];
        Beer? bBeer = beersList[b.beerUuid];
        if (aBeer != null && bBeer != null) {
          int beerComparison = aBeer.compareTo(bBeer);
          if (beerComparison != 0) {
            return beerComparison;
          }
        }
        return a.compareTo(b);
      };
      return super.buildBodyWidget(
        context,
        ref,
        entries,
        comparator: comparator,
      );
    },
  );

  @override
  HistoryEntryWidget buildObjectWidget(HistoryEntry object) => HistoryEntryWidget(historyEntry: object);

  @override
  String getEmptyWidgetText(String? search) => translations.history.page.empty;

  @override
  List<GroupData<HistoryEntry>> Function(List<HistoryEntry>)? groupObjects(BuildContext context, WidgetRef ref) {
    return (entries) {
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
    };
  }
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
    text: intl.DateFormat.yMMMMd(LocaleSettings.currentLocale.languageCode).format(date),
  );

  @override
  TextSpan? get description {
    double? trueQuantity = result.trueQuantity;
    return trueQuantity == null
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
            quantity: NumberFormat.formatDouble(trueQuantity!),
          ),
        ),
      ],
    );
  }

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
