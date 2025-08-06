import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/database/database.dart';
import 'package:beerstory/model/repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bar repository provider.
final barRepositoryProvider = AsyncNotifierProvider<BarRepository, List<Bar>>(BarRepository.new);

/// The repository that handles bars.
class BarRepository extends Repository<Bar> with DatabaseRepository<Bar, DriftBar, Bars> {
  @override
  TableInfo<Bars, DriftBar> getTable(Database database) => database.bars;

  @override
  Insertable<DriftBar> toInsertable(Bar object) => DriftBar(
    uuid: object.uuid,
    name: object.name,
    address: object.address,
    comment: object.comment,
  );

  @override
  Bar toObject(DriftBar insertable) => Bar(
    uuid: insertable.uuid,
    name: insertable.name,
    address: insertable.address,
    comment: insertable.comment,
  );
}
