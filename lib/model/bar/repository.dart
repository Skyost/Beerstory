import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/database.dart';
import 'package:beerstory/model/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bar repository provider.
final barRepositoryProvider = AsyncNotifierProvider<BarRepository, List<Bar>>(BarRepository.new);

/// The repository that handles bars.
class BarRepository extends Repository<Bar> {
  @override
  @protected
  AutoDisposeProvider<BarsDatabase> get databaseProvider => barsDatabaseProvider;
}
