import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/repository_object.dart';

/// Represents a beer.
class Beer extends RepositoryObject {
  /// The beer name.
  String _name;

  /// The beer image.
  String? _image;

  /// The beer tags.
  List<String> _tags;

  /// The beer degrees.
  double? _degrees;

  /// The beer rating.
  double? _rating;

  /// The beer prices.
  List<BeerPrice> _prices;

  /// Creates a new beer instance.
  Beer({
    super.uuid,
    required String name,
    String? image,
    List<String>? tags,
    double? degrees,
    double? rating,
    List<BeerPrice>? prices,
  })  : _name = name,
        _image = image,
        _tags = tags ?? [],
        _degrees = degrees,
        _rating = rating,
        _prices = prices ?? [];

  /// Creates a new beer instance from a JSON map.
  Beer.fromJson(Map<String, dynamic> jsonData)
      : this(
          uuid: jsonData['uuid'],
          name: jsonData['name'],
          image: jsonData['image'],
          tags: [for (dynamic tag in jsonData['tags']) tag.toString()],
          degrees: jsonData['degrees'],
          rating: jsonData['rating'],
          prices: [
            for (dynamic jsonPrice in jsonData['prices']) BeerPrice.fromJson(jsonPrice),
          ],
        );

  /// Returns the beer name.
  String get name => _name;

  /// Changes the beer name.
  set name(String name) {
    _name = name;
    notifyListeners();
  }

  /// Returns the beer image.
  String? get image => _image;

  /// Changes the beer image.
  set image(String? image) {
    _image = image;
    notifyListeners();
  }

  /// Returns the beer tags.
  List<String> get tags => List<String>.from(_tags);

  /// Changes the beer tags.
  set tags(List<String> tags) {
    _tags = tags;
    notifyListeners();
  }

  /// Returns the beer degrees.
  double? get degrees => _degrees;

  /// Changes the beer degrees.
  set degrees(double? degrees) {
    _degrees = degrees;
    notifyListeners();
  }

  /// Returns the beer rating.
  double? get rating => _rating;

  /// Changes the beer rating.
  set rating(double? rating) {
    _rating = rating;
    notifyListeners();
  }

  /// Returns the beer prices.
  List<BeerPrice> get prices => List<BeerPrice>.from(_prices);

  /// Changes the beer prices.
  set prices(List<BeerPrice> prices) {
    _prices = prices.where((price) => !price.isEmpty).toList();
    notifyListeners();
  }

  /// Returns the minimum price.
  BeerPrice? get minimumPrice {
    BeerPrice? result;
    for (BeerPrice price in _prices) {
      if (price.price != null && (result == null || price.price! < result.price!)) {
        result = price;
      }
    }
    return result;
  }

  /// Returns the maximum price.
  BeerPrice? get maximumPrice {
    BeerPrice? result;
    for (BeerPrice price in _prices) {
      if (price.price != null && (result == null || price.price! > result.price!)) {
        result = price;
      }
    }
    return result;
  }

  /// Removes all bar prices from this beer.
  void removeBarPrices(Bar bar, {bool notify = true}) {
    bool hasChanged = false;
    for (BeerPrice price in prices) {
      if (price.barUuid == bar.uuid) {
        _prices.remove(price);
        hasChanged = true;
      }
    }

    if (hasChanged && notify) {
      notifyListeners();
    }
  }

  @override
  String get orderKey => _name.toLowerCase();

  @override
  List<String> get searchTerms => [
        _name,
        ..._tags,
      ];

  @override
  Map<String, dynamic> get jsonData => {
        'name': _name,
        'image': _image,
        'tags': _tags,
        'degrees': _degrees,
        'rating': _rating,
        'prices': _prices,
      };
}

/// Represents a beer price.
class BeerPrice {
  /// The bar UUID.
  String? barUuid;

  /// The price.
  double? price;

  /// Creates a new beer price instance.
  BeerPrice({
    this.barUuid,
    this.price,
  });

  /// Creates a new beer instance from a JSON map.
  BeerPrice.fromJson(Map<String, dynamic> jsonData)
      : this(
          barUuid: jsonData['barUuid'],
          price: jsonData['price'],
        );

  /// Returns whether this price is empty.
  bool get isEmpty => barUuid == null && price == null;

  /// Converts this price to a JSON map.
  Map<String, dynamic> toJson() => {
        'barUuid': barUuid,
        'price': price,
      };

  /// Copies this beer price.
  BeerPrice copy() => BeerPrice(
        barUuid: barUuid,
        price: price,
      );
}
