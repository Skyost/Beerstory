import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/history/entries.dart';
import 'package:beerstory/model/history/entry.dart';
import 'package:beerstory/model/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The history provider.
final historyProvider = ChangeNotifierProvider<History>((ref) => History()..init());

/// The repository that handles the history entries.
class History extends Repository<HistoryEntries> {
  /// Creates a new history instance.
  History()
      : super(
          file: 'history',
        );

  /// Inserts the specified entry at the specified date.
  HistoryEntries insertEntry(DateTime date, HistoryEntry entry, { bool notify = true }) {
    HistoryEntries? dateEntries = findByUuid(HistoryEntries.dateToUuid(date));
    if (dateEntries != null) {
      dateEntries.insertEntry(entry, notify: notify);
    } else {
      dateEntries = HistoryEntries(
        date: date,
        entries: [entry],
      );
      add(dateEntries);

      if (notify) {
        notifyListeners();
      }
    }

    return dateEntries;
  }

  /// Removes an entry from the specified date.
  void removeEntry(DateTime date, HistoryEntry entry, { bool notify = true }) {
    HistoryEntries? dateEntries = findByUuid(HistoryEntries.dateToUuid(date));
    if (dateEntries != null) {
      dateEntries.removeEntry(entry, notify: false);
      if (dateEntries.isEmpty) {
        remove(dateEntries, notify: false);
      }

      if (notify) {
        notifyListeners();
      }
    }
  }

  /// Removes a beer reference from all entries.
  void removeBeer(Beer beer) {
    for (HistoryEntries entries in objects) {
      entries.removeBeer(beer, notify: false);
      if (entries.isEmpty) {
        remove(entries, notify: false);
      }
    }
    notifyListeners();
  }

  @override
  HistoryEntries createObjectFromJson(Map<String, dynamic> jsonData) => HistoryEntries.fromJson(jsonData);
}
