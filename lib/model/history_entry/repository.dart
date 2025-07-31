import 'dart:async';

import 'package:beerstory/model/history_entry/database.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The history provider.
final historyProvider = AsyncNotifierProvider<History, List<HistoryEntry>>(
  History.new,
);

/// The repository that handles history entries.
class History extends Repository<HistoryEntry> {
  Future<void> aborb(HistoryEntry entry) async {
    List<HistoryEntry> entries = await ref.read(databaseProvider).list(date: entry.date);
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
  @protected
  AutoDisposeProvider<HistoryEntriesDatabase> get databaseProvider => historyEntriesDatabaseProvider;
}

/// The last inserted beer provider.
final lastInsertedBeerProvider = StateProvider<String?>((ref) => null);
