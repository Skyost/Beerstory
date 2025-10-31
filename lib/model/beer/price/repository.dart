import 'dart:async';

import 'package:beerstory/model/beer/price/price.dart';
import 'package:beerstory/model/database/database.dart';
import 'package:beerstory/model/repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The beer price repository provider.
final beerPriceRepositoryProvider = AsyncNotifierProvider<BeerPriceRepository, List<BeerPrice>>(BeerPriceRepository.new);

/// The repository that handles beer prices.
class BeerPriceRepository extends Repository<BeerPrice> with DatabaseRepository<BeerPrice, DriftBeerPrice, BeerPrices> {
  @override
  TableInfo<BeerPrices, DriftBeerPrice> getTable(Database database) => database.beerPrices;

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
}

/// The beer prices from beer provider.
final beerPricesFromBeerProvider = AsyncNotifierProvider.autoDispose.family<BeerPriceFromBeerNotifier, List<BeerPrice>, String>(BeerPriceFromBeerNotifier.new);

/// Allows to display the prices of a given beer.
class BeerPriceFromBeerNotifier extends AsyncNotifier<List<BeerPrice>> {
  /// The UUID of the beer.
  final String beerUuid;

  /// Creates a new beer prices from beer notifier instance.
  BeerPriceFromBeerNotifier(this.beerUuid);

  @override
  FutureOr<List<BeerPrice>> build() async {
    List<BeerPrice> prices = await ref.watch(
      beerPriceRepositoryProvider.future,
    );
    return [
      for (BeerPrice price in prices)
        if (price.beerUuid == beerUuid) price,
    ];
  }
}

/// The beer prices from bar provider.
final beerPricesFromBarProvider = AsyncNotifierProvider.autoDispose.family<BeerPriceFromBarNotifier, List<BeerPrice>, String>(BeerPriceFromBarNotifier.new);

/// Allows to display the prices of a given bar.
class BeerPriceFromBarNotifier extends AsyncNotifier<List<BeerPrice>> {
  /// The UUID of the bar.
  final String barUuid;

  /// Creates a new beer prices from bar notifier instance.
  BeerPriceFromBarNotifier(this.barUuid);

  @override
  FutureOr<List<BeerPrice>> build() async {
    List<BeerPrice> prices = await ref.watch(
      beerPriceRepositoryProvider.future,
    );
    return [
      for (BeerPrice price in prices)
        if (price.barUuid == barUuid) price,
    ];
  }
}
