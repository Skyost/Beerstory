import 'dart:convert';

import 'package:beerstory/model/repository_object.dart';
import 'package:beerstory/model/storage/storage.dart';
import 'package:flutter/material.dart';

/// A simple repository.
abstract class Repository<T extends RepositoryObject> with ChangeNotifier {
  /// The storage object.
  @protected
  final Storage storage = Storage();

  /// The repository file.
  final String file;

  /// The repository data.
  final Map<String, T> _data = {};

  /// Whether this repository has been initialized.
  bool _isInitialized = false;

  /// Creates a new repository instance.
  Repository({
    required this.file,
  });

  /// Initializes this repository.
  Future<void> init() async {
    if (await storage.fileExists(file)) {
      Map objects = jsonDecode(await storage.readFile(file));
      for (MapEntry object in objects.entries) {
        T result = createObjectFromJson(object.value);
        add(result, notify: false);
      }
    } else {
      await save();
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Saves this repository.
  Future<void> save() async => await storage.saveFile(file, jsonEncode(_data));

  /// Adds the specified object to this repository.
  void add(T object, { bool notify = true }) {
    object.addListener(notifyListeners);
    _data[object.uuid] = object;
    if (notify) {
      notifyListeners();
    }
  }

  /// Removes the specified object from this repository.
  void remove(T object, { bool notify = true }) {
    object.removeListener(notifyListeners);
    _data.remove(object.uuid);
    if (notify) {
      notifyListeners();
    }
  }

  /// Clears this repository.
  void clear({ bool notify = true }) {
    _data.clear();
    if (notify) {
      notifyListeners();
    }
  }

  /// Returns whether this object is contained inside this repository.
  bool has(T object) => hasUuid(object.uuid);

  /// Returns whether this UUID is contained inside this repository.
  bool hasUuid(String uuid) => _data.containsKey(uuid);

  /// Finds an object by its UUID.
  T? findByUuid(String uuid) => _data[uuid];

  /// Returns the handled objects.
  List<T> get objects => _data.values.toList();

  /// Returns whether this repository is empty.
  bool get isEmpty => _data.isEmpty;

  /// Returns whether this repository has been initialized.
  bool get isInitialized => _isInitialized;

  /// Reads a [T] from JSON data.
  @protected
  T createObjectFromJson(Map<String, dynamic> jsonData);

  @override
  void dispose() {
    for (T object in _data.values) {
      object.dispose();
    }
    super.dispose();
  }
}
