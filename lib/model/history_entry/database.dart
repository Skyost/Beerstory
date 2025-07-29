import 'package:beerstory/model/beer/database.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/utils/riverpod.dart';
import 'package:beerstory/utils/sqlite.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

/// The history entry entries table.
@DataClassName('DriftHistoryEntry')
class HistoryEntries extends Table {
  /// The history entry entry uuid.
  TextColumn get uuid => text().clientDefault(() => const Uuid().v4())();

  /// The history entry entry date.
  DateTimeColumn get date => dateTime().withDefault(currentDate)();

  /// The history entry beer id.
  TextColumn get beerUuid => text().references(Beers, #uuid)();

  /// The history entry entry quantity.
  RealColumn get quantity => real().nullable()();

  /// The number of times this beer has been drank.
  IntColumn get times => integer().withDefault(const Constant(1))();

  /// Whether this is more than the current quantity.
  BoolColumn get moreThanQuantity => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>>? get primaryKey => {uuid};
}

/// The history entries database provider.
final historyEntriesDatabaseProvider = Provider.autoDispose<HistoryEntriesDatabase>((ref) {
  HistoryEntriesDatabase database = HistoryEntriesDatabase();
  ref.onDispose(database.close);
  ref.cacheFor(const Duration(seconds: 1));
  return database;
});

/// The history entries database.
@DriftDatabase(tables: [HistoryEntries])
class HistoryEntriesDatabase extends _$HistoryEntriesDatabase with RepositoryDatabase<HistoryEntry>, GeneratedRepositoryDatabase<HistoryEntry, DriftHistoryEntry, HistoryEntries> {
  /// The database file name.
  static const _kDbFileName = 'history';

  /// Creates a new history entries database instance.
  HistoryEntriesDatabase()
      : super(
          SqliteUtils.openConnection(_kDbFileName),
        );

  @override
  int get schemaVersion => 1;

  @override
  TableInfo<HistoryEntries, DriftHistoryEntry> get table => historyEntries;

  @override
  Insertable<DriftHistoryEntry> toInsertable(HistoryEntry object) => DriftHistoryEntry(
        uuid: object.uuid,
        date: object.date,
        beerUuid: object.beerUuid,
        quantity: object.quantity,
        times: object.times,
        moreThanQuantity: object.moreThanQuantity,
      );

  @override
  HistoryEntry toObject(DriftHistoryEntry insertable) => HistoryEntry(
        uuid: insertable.uuid,
        date: insertable.date,
        beerUuid: insertable.beerUuid,
        quantity: insertable.quantity,
        times: insertable.times,
        moreThanQuantity: insertable.moreThanQuantity,
      );
}
