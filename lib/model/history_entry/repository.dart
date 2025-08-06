import 'dart:async';

import 'package:beerstory/model/database/database.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The history provider.
final historyProvider = AsyncNotifierProvider<History, List<HistoryEntry>>(History.new);

/// The repository that handles history entries.
class History extends Repository<HistoryEntry> with DatabaseRepository<HistoryEntry, DriftHistoryEntry, HistoryEntries> {
  /// Finds the entry with the given [entry.beerUuid] and calls [absorbEntry] on it.
  /// Only calls [add] if no entry is found.
  Future<void> absorb(HistoryEntry entry) async {
    List<HistoryEntry> entries = await future;
    for (HistoryEntry historyEntry in entries) {
      if (historyEntry.beerUuid == entry.beerUuid) {
        await change(historyEntry.absorbEntry(entry));
        return;
      }
    }
    await add(entry);
  }

  @override
  Future<void> add(HistoryEntry object) async {
    await super.add(object);
    ref.read(lastInsertedBeerProvider.notifier).state = object.beerUuid;
  }

  @override
  Future<void> change(HistoryEntry object) async {
    await super.change(object);
    ref.read(lastInsertedBeerProvider.notifier).state = object.beerUuid;
  }

  @override
  TableInfo<HistoryEntries, DriftHistoryEntry> getTable(Database database) => database.historyEntries;

  @override
  Insertable<DriftHistoryEntry> toInsertable(HistoryEntry object) => DriftHistoryEntry(
    uuid: object.uuid,
    date: object.date,
    beerUuid: object.beerUuid,
    quantity: object.quantity,
    times: object.times,
    moreThanQuantity: object.moreThanQuantity,
    comments: object.comments,
  );

  @override
  HistoryEntry toObject(DriftHistoryEntry insertable) => HistoryEntry(
    uuid: insertable.uuid,
    date: insertable.date,
    beerUuid: insertable.beerUuid,
    quantity: insertable.quantity,
    times: insertable.times,
    moreThanQuantity: insertable.moreThanQuantity,
    comments: insertable.comments,
  );
}

/// The last inserted beer provider.
final lastInsertedBeerProvider = StateProvider<String?>((ref) => null);
