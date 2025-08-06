import 'dart:async';

import 'package:beerstory/model/database/database.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// An object that can be stored in a database.
abstract class RepositoryObject {
  /// The object UUID.
  final String uuid;

  /// Creates a new repository object instance.
  RepositoryObject({
    String? uuid,
  }) : uuid = uuid ?? const Uuid().v4();

  @override
  bool operator ==(Object other) {
    if (other is! RepositoryObject) {
      return super == other;
    }
    return identical(this, other) || uuid == other.uuid;
  }

  @override
  int get hashCode => uuid.hashCode;

  /// Creates a copy of this object.
  RepositoryObject copyWith();
}

/// An object that has a name.
mixin HasName on RepositoryObject {
  /// Returns the name of this object.
  String get name;
}

/// A database, required to store objects.
mixin DatabaseRepository<O extends RepositoryObject, I extends DataClass, T extends Table> on Repository<O> {
  /// The associated table.
  @protected
  TableInfo<T, I> getTable(Database database);

  @override
  FutureOr<List<O>> build() async {
    Database database = ref.watch(databaseProvider);
    Stream<List<O>> stream = database.select(getTable(database)).map(toObject).watch();
    StreamSubscription<List<O>> subscription = stream.listen((data) => state = AsyncData(List.of(data)..sort()));
    ref.onDispose(subscription.cancel);
    return List.of(await stream.first)..sort();
  }

  // /// Lists the objects.
  // @protected
  // FutureOr<List<O>> list({int? limit}) async {
  //   Database database = ref.read(databaseProvider);
  //   SimpleSelectStatement<T, I> query = database.select(getTable(database));
  //   if (limit != null) {
  //     query = query..limit(limit);
  //   }
  //   return await query.map(toObject).get();
  // }

  @override
  FutureOr<void> add(O object) async {
    Database database = ref.read(databaseProvider);
    Insertable<I> insertable = toInsertable(object);
    await database.into(getTable(database)).insert(insertable);
    await super.add(object);
  }

  @override
  FutureOr<void> change(O object) async {
    Database database = ref.read(databaseProvider);
    Insertable<I> insertable = toInsertable(object);
    await database.update(getTable(database)).replace(insertable);
    await super.change(object);
  }

  @override
  FutureOr<void> remove(O object) async {
    Database database = ref.read(databaseProvider);
    Insertable<I> insertable = toInsertable(object);
    await database.delete(getTable(database)).delete(insertable);
    await super.remove(object);
  }

  @override
  FutureOr<void> clear() async {
    Database database = ref.read(databaseProvider);
    await database.delete(getTable(database)).go();
    await super.clear();
  }

  /// Converts the specified [object] to an [Insertable].
  Insertable<I> toInsertable(O object);

  /// Converts the specified [I] to an [O].
  O toObject(I insertable);
}

/// A simple repository.
abstract class Repository<T extends RepositoryObject> extends AsyncNotifier<List<T>> {
  /// Adds the specified object to this repository.
  FutureOr<void> add(T object) async {
    List<T> newState = [...(await future), object]..sort();
    state = AsyncData(newState);
  }

  /// Updates the specified object in this repository.
  FutureOr<void> change(T object) async {
    List<T> newState = [
      for (T item in await future)
        if (item.uuid == object.uuid) object else item,
    ]..sort();
    state = AsyncData(newState);
  }

  /// Removes the specified object from this repository.
  FutureOr<void> remove(T object) async {
    List<T> newState = List.of(await future)..remove(object);
    state = AsyncData(newState);
  }

  /// Clears this repository.
  FutureOr<void> clear() async {
    state = const AsyncData([]);
  }

  @override
  bool updateShouldNotify(AsyncValue<List<T>> previous, AsyncValue<List<T>> next) {
    bool wasLoading = previous.isLoading;
    bool isLoading = next.isLoading;

    if (wasLoading || isLoading) {
      return wasLoading != isLoading;
    }

    return !listEquals(previous.value, next.value);
  }
}

/// Some useful methods to use alongside objects list.
extension ByUuid<T extends RepositoryObject> on List<T> {
  /// Returns the first object with the given uuid.
  T? findByUuid(String uuid) => firstWhereOrNull((object) => object.uuid == uuid);
}
