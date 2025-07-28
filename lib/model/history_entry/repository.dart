import 'package:beerstory/model/history_entry/database.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The history provider.
final historyProvider = AsyncNotifierProvider<History, List<HistoryEntry>>(History.new);

/// The repository that handles history entries.
class History extends Repository<HistoryEntry> {
  @override
  @protected
  AutoDisposeProvider<RepositoryDatabase<HistoryEntry>> get databaseProvider => historyEntriesDatabaseProvider;
}
