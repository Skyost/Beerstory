import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history/entries.dart';
import 'package:beerstory/model/history/entry.dart';
import 'package:beerstory/model/history/history.dart';
import 'package:beerstory/model/migration/old_objects/bar.dart';
import 'package:beerstory/model/migration/old_objects/beer.dart';
import 'package:beerstory/model/migration/old_objects/history.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/model/repository_object.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Allows to migrate old app data.
class Migrator {
  /// Initializes the migrator.
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter<OldBeer>(BeerAdapter());
    Hive.registerAdapter<OldBeerPrice>(BeerPriceAdapter());
    Hive.registerAdapter<OldBar>(BarAdapter());
    Hive.registerAdapter<OldHistoryEntries>(HistoryEntriesAdapter());
    Hive.registerAdapter<OldHistoryEntry>(HistoryEntryAdapter());
  }

  /// Migrates all repositories.
  static Future<void> migrate(WidgetRef ref) async {
    Map<Type, Map<dynamic, RepositoryObject>> oldIds = {};
    await _migrateRepository(ref.read(barRepositoryProvider), oldIds);
    await _migrateRepository(ref.read(beerRepositoryProvider), oldIds);
    await _migrateRepository(ref.read(historyProvider), oldIds);
  }

  /// Starts the migration for the given repository.
  static Future<void> _migrateRepository<T extends HiveObject>(Repository repository, Map<Type, Map<dynamic, RepositoryObject>> oldIds) async {
    if (!(await Hive.boxExists(repository.file))) {
      return;
    }
    Box<T> box = await Hive.openBox<T>(repository.file);
    for (T value in box.values) {
      RepositoryObject? newObject = _migrateOldObject<T>(value, oldIds);
      if (newObject != null) {
        oldIds[value.runtimeType] = (oldIds[value.runtimeType] ?? {})..[value.key] = newObject;
        repository.add(newObject);
      }
    }
    await repository.save();
    await box.deleteFromDisk();
  }

  /// Migrates an old object to a new one.
  static RepositoryObject? _migrateOldObject<T extends HiveObject>(T object, Map<Type, Map<dynamic, RepositoryObject>> oldIds) {
    if (object is OldBeer) {
      return _migrateOldBeer(object, oldIds[OldBar] ?? {});
    }
    if (object is OldBar) {
      return _migrateOldBar(object);
    }
    if (object is OldHistoryEntries) {
      return _migrateOldHistoryEntries(object, oldIds[OldBeer] ?? {});
    }
    return null;
  }

  /// Migrates an old beer object.
  static Beer _migrateOldBeer(OldBeer oldBeer, Map<dynamic, RepositoryObject> oldBarIds) => Beer(
        name: oldBeer.name,
        image: oldBeer.image,
        tags: oldBeer.tags,
        degrees: oldBeer.degrees,
        rating: oldBeer.rating,
        prices: oldBeer.prices?.map((price) => _migrateOldBeerPrice(price, oldBarIds)).toList(),
      );

  /// Migrates an old beer price object.
  static BeerPrice _migrateOldBeerPrice(OldBeerPrice oldBeerPrice, Map<dynamic, RepositoryObject> oldBarIds) => BeerPrice(
        barUuid: oldBarIds[oldBeerPrice.barId]?.uuid,
        price: oldBeerPrice.price,
      );

  /// Migrates an old bar object.
  static Bar _migrateOldBar(OldBar oldBar) => Bar(
        name: oldBar.name,
        address: oldBar.address,
      );

  /// Migrates an old history entries object.
  static HistoryEntries _migrateOldHistoryEntries(OldHistoryEntries oldHistoryEntries, Map<dynamic, RepositoryObject> oldBeerIds) => HistoryEntries(
        date: OldHistoryEntries.formatter.parse(oldHistoryEntries.key),
        entries: oldHistoryEntries.entries?.map((historyEntry) => _migrateOldHistoryEntry(historyEntry, oldBeerIds)).toList(),
      );

  /// Migrates an old history entry object.
  static HistoryEntry _migrateOldHistoryEntry(OldHistoryEntry oldHistoryEntry, Map<dynamic, RepositoryObject> oldBeerIds) => HistoryEntry(
    beer: oldBeerIds[oldHistoryEntry.beerId] as Beer,
    quantity: oldHistoryEntry.quantity,
    times: oldHistoryEntry.times,
    moreThanQuantity: oldHistoryEntry.moreThanQuantity,
  );
}

/// A repository object with an old Hive id.
class RepositoryObjectOldId {
  /// The object.
  final RepositoryObject object;
  /// The old Hive id.
  final dynamic oldId;

  /// Creates a new repository object old id instance.
  const RepositoryObjectOldId({required this.object, required this.oldId,});
}
