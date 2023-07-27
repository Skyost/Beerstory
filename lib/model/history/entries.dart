import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/history/entry.dart';
import 'package:beerstory/model/repository_object.dart';
import 'package:intl/intl.dart';

/// Represents a list of history entries associated with a date.
class HistoryEntries extends RepositoryObject {
  /// The key date formatter.
  static final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  /// The entries list.
  final List<HistoryEntry> _entries;

  /// Creates a new history entries instance.
  HistoryEntries({
    required DateTime date,
    required List<HistoryEntry>? entries,
  })  : _entries = entries ?? [],
        super(
          uuid: dateToUuid(date),
        ) {
    for (HistoryEntry entry in _entries) {
      entry.addListener(notifyListeners);
    }
  }

  /// Creates a new history entries instance from a JSON map.
  HistoryEntries.fromJson(Map<String, dynamic> jsonData)
      : this(
          date: _formatter.parse(jsonData['date']),
          entries: [
            for (dynamic jsonEntry in jsonData['entries']) HistoryEntry.fromJson(jsonEntry),
          ],
        );

  /// Inserts the specified history entry to the current instance.
  void insertEntry(HistoryEntry entry, {bool notify = true}) {
    for (HistoryEntry dateEntry in _entries) {
      if (dateEntry.beerUuid == entry.beerUuid) {
        dateEntry.absorbEntry(entry);
        return;
      }
    }

    _entries.add(entry);
    if (notify) {
      notifyListeners();
    }
  }

  /// Removes a beer from the entries.
  void removeBeer(Beer beer, {bool notify = true}) {
    bool hasChanged = false;
    for (HistoryEntry entry in entries) {
      if (entry.beerUuid == beer.uuid) {
        _entries.remove(entry);
        hasChanged = true;
      }
    }
    if (hasChanged && notify) {
      notifyListeners();
    }
  }

  /// Removes the specified entry.
  void removeEntry(HistoryEntry entry, {bool notify = true}) {
    _entries.remove(entry);
    if (notify) {
      notifyListeners();
    }
  }

  /// The entries count.
  int get count => _entries.length;

  /// Returns whether there is no more entry.
  bool get isEmpty => _entries.isEmpty;

  /// Returns the [n]-th entry.
  HistoryEntry operator [](int n) => _entries[n];

  /// Returns the entries.
  List<HistoryEntry> get entries => List<HistoryEntry>.from(_entries);

  /// Converts a date to a history entries UUID.
  static String dateToUuid(DateTime date) => _formatter.format(date);

  /// Returns the date.
  DateTime get date => _formatter.parse(uuid);

  @override
  Comparable get orderKey => uuid;

  @override
  Map<String, dynamic> get jsonData => {
        'date': _formatter.format(date),
        'entries': _entries,
      };

  @override
  void dispose() {
    for (HistoryEntry entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }
}
