import 'package:beerstory/model/repository.dart';
import 'package:beerstory/utils/compare_fields.dart';

/// Represents a beer price.
class BeerPrice extends RepositoryObject implements Comparable<BeerPrice> {
  /// The beer UUID.
  final String beerUuid;

  /// The bar UUID.
  final String? barUuid;

  /// The price amount.
  final double amount;

  /// Creates a new beer price instance.
  BeerPrice({
    super.uuid,
    required this.beerUuid,
    this.barUuid,
    this.amount = 0,
  });

  @override
  bool operator ==(Object other) {
    if (other is! BeerPrice) {
      return super == other;
    }
    return identical(this, other) || (uuid == other.uuid && beerUuid == other.beerUuid && barUuid == other.barUuid && amount == other.amount);
  }

  @override
  int get hashCode => Object.hash(uuid, beerUuid, barUuid, amount);

  @override
  BeerPrice copyWith({
    String? uuid,
    String? beerUuid,
    String? barUuid,
    double? amount,
  }) =>
      BeerPrice(
        uuid: uuid ?? this.uuid,
        beerUuid: beerUuid ?? this.beerUuid,
        barUuid: barUuid ?? this.barUuid,
        amount: amount ?? this.amount,
      );

  /// Overwrites the [BeerPrice.barUuid] field.
  BeerPrice overwriteBar({String? barUuid}) => BeerPrice(
        uuid: uuid,
        beerUuid: beerUuid,
        barUuid: barUuid,
        amount: amount,
      );

  @override
  int compareTo(BeerPrice other) => compareAccordingToFields<BeerPrice>(
        this,
        other,
        (price) => [
          price.amount,
          price.barUuid,
          price.beerUuid,
          price.uuid,
        ],
      );
}

/// Some useful methods to use alongside prices list.
extension PriceList on List<BeerPrice> {
  /// Returns the minimum price.
  BeerPrice? get minimumPrice {
    BeerPrice? min;
    for (BeerPrice price in this) {
      if (min == null || price.amount < min.amount) {
        min = price;
      }
    }
    return min;
  }

  /// Returns the maximum price.
  BeerPrice? get maximumPrice {
    BeerPrice? max;
    for (BeerPrice price in this) {
      if (max == null || price.amount > max.amount) {
        max = price;
      }
    }
    return max;
  }
}
