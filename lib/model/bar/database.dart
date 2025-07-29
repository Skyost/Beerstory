import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/utils/riverpod.dart';
import 'package:beerstory/utils/sqlite.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

/// The bars table.
@DataClassName('DriftBar')
class Bars extends Table {
  /// The bar uuid.
  TextColumn get uuid => text().clientDefault(() => const Uuid().v4())();

  /// The bar name.
  TextColumn get name => text()();

  /// The bar address.
  TextColumn get address => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {uuid};
}

/// The bars database provider.
final barsDatabaseProvider = Provider.autoDispose<BarsDatabase>((ref) {
  BarsDatabase database = BarsDatabase();
  ref.onDispose(database.close);
  ref.cacheFor(const Duration(seconds: 1));
  return database;
});

/// The bars database.
@DriftDatabase(tables: [Bars])
class BarsDatabase extends _$BarsDatabase with RepositoryDatabase<Bar>, GeneratedRepositoryDatabase<Bar, DriftBar, Bars> {
  /// The database file name.
  static const _kDbFileName = 'bars';

  /// Creates a new bars database instance.
  BarsDatabase()
      : super(
          SqliteUtils.openConnection(_kDbFileName),
        );

  @override
  int get schemaVersion => 1;

  @override
  TableInfo<Bars, DriftBar> get table => bars;

  @override
  Insertable<DriftBar> toInsertable(Bar object) => DriftBar(
        uuid: object.uuid,
        name: object.name,
        address: object.address,
      );

  @override
  Bar toObject(DriftBar insertable) => Bar(
        uuid: insertable.uuid,
        name: insertable.name,
        address: insertable.address,
      );
}
