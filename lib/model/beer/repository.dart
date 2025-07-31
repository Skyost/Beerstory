import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/database.dart';
import 'package:beerstory/model/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The beer repository provider.
final beerRepositoryProvider = AsyncNotifierProvider<BeerRepository, List<Beer>>(BeerRepository.new);

/// The repository that handles beers.
class BeerRepository extends Repository<Beer> {
  @override
  @protected
  AutoDisposeProvider<BeersDatabase> get databaseProvider => beersDatabaseProvider;
}
