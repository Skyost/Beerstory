import 'package:beerstory/widgets/order/findable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Represents a repository object.
abstract class RepositoryObject with Findable, ChangeNotifier {
  /// The UUID.
  final String uuid;

  /// Creates a new repository object instance.
  RepositoryObject({
    String? uuid,
  }) : uuid = uuid ?? const Uuid().v1();

  /// Converts this object to a JSON map.
  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        ...jsonData,
      };

  /// The JSON data.
  Map<String, dynamic> get jsonData;
}
