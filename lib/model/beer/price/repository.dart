import 'dart:async';

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
final beerPricesFromBeerProvider = AsyncNotifierProvider.autoDispose.family<BeerPriceFromBeerNotifier, List<BeerPrice>, String>(BeerPriceFromBeerNotifier.new);

/// Allows to display the prices of a given beer.
class BeerPriceFromBeerNotifier extends AutoDisposeFamilyAsyncNotifier<List<BeerPrice>, String> {
  @override
  FutureOr<List<BeerPrice>> build(String beerUuid) async {
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
final beerPricesFromBarProvider = AsyncNotifierProvider.autoDispose.family<BeerPriceFromBarNotifier, List<BeerPrice>, String>(
  BeerPriceFromBarNotifier.new,
);

/// Allows to display the prices of a given bar.
class BeerPriceFromBarNotifier extends AutoDisposeFamilyAsyncNotifier<List<BeerPrice>, String> {
  @override
  FutureOr<List<BeerPrice>> build(String barUuid) async {
    List<BeerPrice> prices = await ref.watch(
      beerPriceRepositoryProvider.future,
    );
    return [
      for (BeerPrice price in prices)
        if (price.barUuid == barUuid) price,
    ];
  }
}
