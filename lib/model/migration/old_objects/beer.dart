import 'package:hive/hive.dart';

part 'beer.g.dart';

/// Represents a beer.
@HiveType(typeId: 1)
class OldBeer extends HiveObject {
  /// The beer name.
  @HiveField(0)
  String name;

  /// The beer image.
  @HiveField(1)
  String? image;

  /// The beer tags.
  @HiveField(2)
  List<String>? tags;

  /// The beer degrees.
  @HiveField(3)
  double? degrees;

  /// The beer rating.
  @HiveField(4)
  double? rating;

  /// The beer prices.
  @HiveField(5)
  List<OldBeerPrice>? prices;

  /// Creates a new beer instance.
  OldBeer({
    required this.name,
    this.image,
    this.tags,
    this.degrees,
    this.rating,
    this.prices,
  });
}

/// Represents a price associated with a bar.
@HiveType(typeId: 2)
class OldBeerPrice extends HiveObject {
  /// The bar id.
  @HiveField(0)
  int? barId;

  /// The price.
  @HiveField(1)
  double? price;

  /// Creates a new beer price instance.
  OldBeerPrice({
    this.barId,
    this.price,
  });
}
