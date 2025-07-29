import 'dart:async';

import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/price/database.dart';
import 'package:beerstory/model/beer/price/price.dart';
import 'package:beerstory/model/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The beer price repository provider.
final beerPriceRepositoryProvider = AsyncNotifierProvider<BeerPriceRepository, List<BeerPrice>>(BeerPriceRepository.new);

/// The repository that handles beer prices.
class BeerPriceRepository extends Repository<BeerPrice> {
  @override
  @protected
  AutoDisposeProvider<RepositoryDatabase<BeerPrice>> get databaseProvider => beerPricesDatabaseProvider;
}

/// The beer prices from beer provider.
final beerPricesFromBeerProvider = AsyncNotifierProvider.family.autoDispose<BeerPriceFromBeerNotifier, List<BeerPrice>, Beer>(BeerPriceFromBeerNotifier.new);

/// Allows to display the prices of a given beer.
class BeerPriceFromBeerNotifier extends AutoDisposeFamilyAsyncNotifier<List<BeerPrice>, Beer> {
  @override
  FutureOr<List<BeerPrice>> build(Beer arg) async {
    List<BeerPrice> prices = await ref.watch(beerPriceRepositoryProvider.future);
    return [
      for (BeerPrice price in prices)
        if (price.beerUuid == arg.uuid) price,
    ];
  }
}

/// The beer prices from bar provider.
final beerPricesFromBarProvider = AsyncNotifierProvider.family.autoDispose<BeerPriceFromBarNotifier, List<BeerPrice>, Bar>(BeerPriceFromBarNotifier.new);

/// Allows to display the prices of a given bar.
class BeerPriceFromBarNotifier extends AutoDisposeFamilyAsyncNotifier<List<BeerPrice>, Bar> {
  @override
  FutureOr<List<BeerPrice>> build(Bar arg) async {
    List<BeerPrice> prices = await ref.watch(beerPriceRepositoryProvider.future);
    return [
      for (BeerPrice price in prices)
        if (price.barUuid == arg.uuid) price,
    ];
  }
}
