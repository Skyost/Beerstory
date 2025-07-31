import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/utils/riverpod.dart';
import 'package:beerstory/utils/sqlite.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'database.g.dart';

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

/// The beers database provider.
final beersDatabaseProvider = Provider.autoDispose<BeersDatabase>((ref) {
  BeersDatabase database = BeersDatabase();
  ref.onDispose(database.close);
  ref.cacheFor(const Duration(seconds: 1));
  return database;
});

/// The beers database.
@DriftDatabase(tables: [Beers])
class BeersDatabase extends _$BeersDatabase with RepositoryDatabase<Beer>, GeneratedRepositoryDatabase<Beer, DriftBeer, Beers> {
  /// The database file name.
  static const _kDbFileName = 'beers';

  /// Creates a new beers database instance.
  BeersDatabase()
    : super(
        SqliteUtils.openConnection(_kDbFileName),
      );

  @override
  int get schemaVersion => 1;

  @override
  TableInfo<Beers, DriftBeer> get table => beers;

  @override
  Insertable<DriftBeer> toInsertable(Beer object) => DriftBeer(
    uuid: object.uuid,
    name: object.name,
    image: object.image,
    tags: object.tags,
    degrees: object.degrees,
    rating: object.rating,
  );

  @override
  Beer toObject(DriftBeer insertable) => Beer(
    uuid: insertable.uuid,
    name: insertable.name,
    image: insertable.image,
    tags: insertable.tags,
    degrees: insertable.degrees,
    rating: insertable.rating,
  );

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
