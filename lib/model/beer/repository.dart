import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/database/database.dart';
import 'package:beerstory/model/history_entry/repository.dart';
import 'package:beerstory/model/repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The beer repository provider.
final beerRepositoryProvider = AsyncNotifierProvider<BeerRepository, List<Beer>>(BeerRepository.new);

/// The repository that handles beers.
class BeerRepository extends Repository<Beer> with DatabaseRepository<Beer, DriftBeer, Beers> {
  @override
  TableInfo<Beers, DriftBeer> getTable(Database database) => database.beers;

  @override
  Insertable<DriftBeer> toInsertable(Beer object) => DriftBeer(
    uuid: object.uuid,
    name: object.name,
    image: object.image,
    tags: object.tags,
    degrees: object.degrees,
    rating: object.rating,
    comment: object.comment,
  );

  @override
  Beer toObject(DriftBeer insertable) => Beer(
    uuid: insertable.uuid,
    name: insertable.name,
    image: insertable.image,
    tags: insertable.tags,
    degrees: insertable.degrees,
    rating: insertable.rating,
    comment: insertable.comment,
  );

  @override
  Future<void> remove(Beer object) async {
    await super.remove(object);
    if (object.uuid == ref.read(lastInsertedBeerProvider)) {
      ref.read(lastInsertedBeerProvider.notifier).state = null;
    }
  }
}
