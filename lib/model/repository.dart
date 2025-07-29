import 'dart:async';

import 'package:beerstory/utils/utils.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart' hide Table;
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
mixin RepositoryDatabase<O extends RepositoryObject> {
  /// Lists the objects.
  FutureOr<List<O>> list({int? limit});

  /// Adds the specified object.
  FutureOr<void> add(O object);

  /// Updates the specified object.
  FutureOr<void> change(O object);

  /// Removes the specified object.
  FutureOr<void> remove(O object);

  /// Clears all objects from the database.
  FutureOr<void> clear();
}

/// Utility mixin to use the [RepositoryDatabase] interface with [GeneratedDatabase].
mixin GeneratedRepositoryDatabase<O extends RepositoryObject, I extends DataClass, T extends Table> on RepositoryDatabase<O>, GeneratedDatabase {
  /// The associated table.
  @protected
  TableInfo<T, I> get table;

  @override
  FutureOr<List<O>> list({int? limit}) async {
    SimpleSelectStatement<T, I> query = select(table);
    if (limit != null) {
      query = query..limit(limit);
    }
    return (await query.get()).map(toObject).toList();
  }

  @override
  FutureOr<void> add(O object) async {
    Insertable<I> insertable = toInsertable(object);
    await into(table).insert(insertable);
  }

  @override
  FutureOr<void> change(O object) async {
    Insertable<I> insertable = toInsertable(object);
    await update(table).replace(insertable);
  }

  @override
  FutureOr<void> remove(O object) async {
    Insertable<I> insertable = toInsertable(object);
    await delete(table).delete(insertable);
  }

  @override
  FutureOr<void> clear() async {
    await delete(table).go();
  }

  /// Converts the specified [object] to an [Insertable].
  Insertable<I> toInsertable(O object);

  /// Converts the specified [I] to an [O].
  O toObject(I insertable);
}

/// A simple repository.
abstract class Repository<T extends RepositoryObject> extends AsyncNotifier<List<T>> {
  @override
  FutureOr<List<T>> build() async {
    RepositoryDatabase<T> database = ref.watch(databaseProvider);
    return await database.list()
      ..sort();
  }

  /// Adds the specified object to this repository.
  Future<void> add(T object) async {
    await ref.read(databaseProvider).add(object);
    List<T> newState = [...(await future), object]..sort();
    state = AsyncData(newState);
  }

  /// Updates the specified object in this repository.
  Future<void> change(T object) async {
    await ref.read(databaseProvider).change(object);
    List<T> newState = [
      for (T item in await future)
        if (item.uuid == object.uuid) object else item,
    ]..sort();
    state = AsyncData(newState);
  }

  /// Removes the specified object from this repository.
  Future<void> remove(T object) async {
    await ref.read(databaseProvider).remove(object);
    List<T> newState = List.of(await future)..remove(object);
    state = AsyncData(newState);
  }

  /// Clears this repository.
  Future<void> clear({bool notify = true}) async {
    await ref.read(databaseProvider).clear();
    state = const AsyncData([]);
  }

  /// The database provider.
  @protected
  AutoDisposeProvider<RepositoryDatabase<T>> get databaseProvider;
}

/// Some useful methods to use alongside objects list.
extension ByUuid<T extends RepositoryObject> on List<T> {
  /// Returns the first object with the given uuid.
  T? findByUuid(String uuid) => firstWhereOrNull((object) => object.uuid == uuid);
}
