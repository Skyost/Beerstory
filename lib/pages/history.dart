import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/history_entry/repository.dart';
import 'package:beerstory/pages/body.dart';
import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:beerstory/widgets/error.dart';
import 'package:beerstory/widgets/ordered_list_view.dart';
import 'package:beerstory/widgets/repository/history_entry.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The history scaffold body widget.
class HistoryScaffoldBody extends ScaffoldBodyWidget<HistoryEntry, History> {
  /// Creates a new history scaffold body widget instance.
  HistoryScaffoldBody({
    super.key,
  }) : super(
          emptyMessage: translations.history.page.empty,
          reverseOrder: true,
        );

  @override
  AsyncNotifierProvider<History, List<HistoryEntry>> get repositoryProvider => historyProvider;

  @override
  Widget buildBodyWidget(WidgetRef ref, List<HistoryEntry> entries) {
    AsyncValue<List<Beer>> beers = ref.watch(beerRepositoryProvider);

    if (beers.isLoading) {
      return const CenteredCircularProgressIndicator();
    }

    if (beers.hasError) {
      return ErrorWidget(
        error: beers.error!,
        stackTrace: beers.stackTrace,
        onRetryPressed: () => ref.refresh(beerRepositoryProvider),
      );
    }

    Map<String, Beer> beersList = {
      for (Beer beer in beers.value!) beer.uuid: beer,
    };
    return OrderedListView<HistoryEntry>(
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
            groupedEntries[date]!.objects.add(entry);
          } else {
            groupedEntries[date] = _DateGroupData(
              date: date,
              objects: [entry],
            );
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
    );
  }
}

/// A group data that contains a [date].
class _DateGroupData extends GroupData<HistoryEntry> {
  /// The date.
  final DateTime date;

  /// Creates a new date group data instance.
  const _DateGroupData({
    required this.date,
    super.objects,
  });

  @override
  String get label => DateFormat.yMMMMd(LocaleSettings.currentLocale.languageCode).format(date);

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
