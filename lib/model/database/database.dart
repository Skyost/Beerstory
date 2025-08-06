import 'dart:io';

import 'package:beerstory/model/database/database.steps.dart';
import 'package:beerstory/utils/riverpod.dart';
import 'package:beerstory/utils/sqlite.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// The bars table.
@DataClassName('DriftBar')
class Bars extends Table {
  /// The bar uuid.
  TextColumn get uuid => text()();

  /// The bar name.
  TextColumn get name => text()();

  /// The bar address.
  TextColumn get address => text().nullable()();

  /// Additional comment on the bar.
  TextColumn get comment => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {uuid};
}

/// The beers table.
@DataClassName('DriftBeer')
class Beers extends Table {
  /// The beer id.
  TextColumn get uuid => text()();

  /// The beer name.
  TextColumn get name => text()();

  /// The beer image.
  TextColumn get image => text().nullable()();

  /// The beer tags.
  TextColumn get tags => text().map(const StringListConverter())();

  /// The beer degrees.
  RealColumn get degrees => real().nullable()();

  /// The beer rating.
  RealColumn get rating => real().nullable()();

  /// Additional comment on the beer.
  TextColumn get comment => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {uuid};
}

/// The beer prices table.
@DataClassName('DriftBeerPrice')
class BeerPrices extends Table {
  /// The beer price id.
  TextColumn get uuid => text()();

  /// The beer price beer id.
  TextColumn get beerUuid => text().references(Beers, #uuid, onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();

  /// The beer price bar id.
  TextColumn get barUuid => text().nullable().references(Bars, #uuid, onUpdate: KeyAction.cascade, onDelete: KeyAction.setNull)();

  /// The beer price amount.
  RealColumn get amount => real()();

  @override
  Set<Column<Object>>? get primaryKey => {uuid};
}

/// The history entry entries table.
@DataClassName('DriftHistoryEntry')
class HistoryEntries extends Table {
  /// The history entry entry uuid.
  TextColumn get uuid => text()();

  /// The history entry entry date.
  DateTimeColumn get date => dateTime()();

  /// The history entry beer id.
  TextColumn get beerUuid => text().references(Beers, #uuid, onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();

  /// The history entry entry quantity.
  RealColumn get quantity => real().nullable()();

  /// The number of times this beer has been drank.
  IntColumn get times => integer()();

  /// Whether this is more than the current quantity.
  BoolColumn get moreThanQuantity => boolean()();

  /// Additional comment on the history entry.
  TextColumn get comment => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {uuid};
}

/// Allows to store [String] list into Drift databases.
class StringListConverter extends TypeConverter<List<String>, String> {
  /// Creates a new String list converter instance.
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) => fromDb.isEmpty ? [] : fromDb.split(',');

  @override
  String toSql(List<String> value) => value.join(',');
}

/// The database provider.
final databaseProvider = Provider.autoDispose<Database>((ref) {
  Database database = Database._(ref: ref);
  ref.onDispose(database.close);
  ref.cacheFor(const Duration(seconds: 1));
  return database;
});

/// The app database.
@DriftDatabase(tables: [Bars, Beers, BeerPrices, HistoryEntries])
class Database extends _$Database {
  /// The database file name.
  static const String _dbFileName = 'data';

  /// The Riverpod ref instance.
  final Ref _ref;

  /// Creates a new database instance.
  Database._({
    required Ref ref,
  }) : _ref = ref,
        super(
         SqliteUtils.openConnection(
               _dbFileName,
             ),
       );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
    onUpgrade: (migrator, from, to) async {
      await migrator.runMigrationSteps(
        from: from,
        to: to,
        steps: migrationSteps(
          from1To2: (migrator, schema) async {
            await migrator.addColumn(schema.bars, schema.bars.comment);
            await migrator.addColumn(schema.beers, schema.beers.comment);
            await migrator.addColumn(schema.historyEntries, schema.historyEntries.comment);
          }
        )
      );
    }
  );

  /// Exports the database from a given [file].
  Future<void> importFrom(File file) async {
    if (path.isWithin((await getApplicationSupportDirectory()).path, file.path) && path.basenameWithoutExtension(file.path) == _dbFileName && path.extension(file.path) == '.db') {
      return;
    }
    await customStatement('ATTACH DATABASE ? AS imported', [file.path]);
    for (TableInfo<Table, Object?> table in allTables) {
      await customStatement('INSERT OR REPLACE INTO ${table.actualTableName} SELECT * FROM imported.${table.actualTableName}');
    }
    await customStatement('DETACH DATABASE imported');
    _ref.invalidateSelf();
  }

  /// Exports the database into a given [file].
  Future<void> exportInto(File file) async {
    await file.parent.create(recursive: true);
    if (file.existsSync()) {
      file.deleteSync();
    }
    await customStatement('VACUUM INTO ?', [file.path]);
  }
}
