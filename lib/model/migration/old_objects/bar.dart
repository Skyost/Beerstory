import 'package:hive/hive.dart';

part 'bar.g.dart';

/// Represents a bar.
@HiveType(typeId: 0)
class OldBar extends HiveObject {
  /// The bar name.
  @HiveField(0)
  String name;

  /// The bar address.
  @HiveField(1)
  String? address;

  /// Creates a new bar instance.
  OldBar({
    required this.name,
    this.address,
  });
}
