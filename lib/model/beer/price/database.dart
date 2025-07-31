import 'package:beerstory/model/bar/database.dart';
import 'package:beerstory/model/beer/database.dart';
import 'package:beerstory/model/beer/price/price.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/utils/riverpod.dart';
import 'package:beerstory/utils/sqlite.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'database.g.dart';

/// The beer prices table.
@DataClassName('DriftBeerPrice')
class BeerPrices extends Table {
  /// The beer price id.
  TextColumn get uuid => text()();

  /// The beer price beer id.
  TextColumn get beerUuid => text().references(Beers, #uuid, onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();

  /// The beer price bar id.
  TextColumn get barUuid => text().references(Bars, #uuid, onUpdate: KeyAction.cascade, onDelete: KeyAction.setNull).nullable()();

  /// The beer price amount.
  RealColumn get amount => real()();

  @override
  Set<Column<Object>>? get primaryKey => {uuid};
}

/// The beer prices database provider.
final beerPricesDatabaseProvider = Provider.autoDispose<BeerPricesDatabase>((ref) {
  BeerPricesDatabase database = BeerPricesDatabase();
  ref.onDispose(database.close);
  ref.cacheFor(const Duration(seconds: 1));
  return database;
});

/// The beer prices database.
@DriftDatabase(tables: [BeerPrices])
class BeerPricesDatabase extends _$BeerPricesDatabase with RepositoryDatabase<BeerPrice>, GeneratedRepositoryDatabase<BeerPrice, DriftBeerPrice, BeerPrices> {
  /// The database file name.
  static const _kDbFileName = 'prices';

  /// Creates a new beer prices database instance.
  BeerPricesDatabase()
    : super(
        SqliteUtils.openConnection(_kDbFileName),
      );

  @override
  int get schemaVersion => 1;

  @override
  TableInfo<BeerPrices, DriftBeerPrice> get table => beerPrices;

  @override
  Insertable<DriftBeerPrice> toInsertable(BeerPrice object) => DriftBeerPrice(
    uuid: object.uuid,
    beerUuid: object.beerUuid,
    barUuid: object.barUuid,
    amount: object.amount,
  );

  @override
  BeerPrice toObject(DriftBeerPrice insertable) => BeerPrice(
    uuid: insertable.uuid,
    beerUuid: insertable.beerUuid,
    barUuid: insertable.barUuid,
    amount: insertable.amount,
  );

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
