import 'package:beerstory/model/beer/beer.dart';
import 'package:flutter/material.dart';

/// Represents an history entry.
class HistoryEntry with ChangeNotifier {
  /// The beer UUID.
  String _beerUuid;

  /// The quantity.
  double? _quantity;

  /// The number of times this beer has been drank.
  int _times;

  /// Whether this is more than the current quantity.
  late bool _moreThanQuantity;

  /// Creates a new history entry instance.
  HistoryEntry({
    required Beer beer,
    double? quantity,
    int times = 1,
    bool? moreThanQuantity,
  })  : _beerUuid = beer.uuid,
        _quantity = quantity,
        _times = times, _moreThanQuantity = moreThanQuantity ?? (quantity == null);

  /// Creates a new history entry instance from a JSON map.
  HistoryEntry.fromJson(Map<String, dynamic> jsonData)
      : _beerUuid = jsonData['beer'],
        _quantity = jsonData['quantity'],
        _times = jsonData['times'],
        _moreThanQuantity = jsonData['moreThanQuantity'];

  /// Returns the beer UUID.
  String get beerUuid => _beerUuid;

  /// Sets the beer UUID.
  set beerUuid(String beerUuid) {
    _beerUuid = beerUuid;
    notifyListeners();
  }

  /// Returns the quantity.
  double? get quantity => _quantity;

  /// Sets the quantity.
  set quantity(double? quantity) {
    _quantity = quantity;
    updateMoreThanQuantity();
  }

  /// Calculates the true quantity drunk.
  double? calculateTrueQuantity(double? rawQuantity) => rawQuantity == null ? null : (rawQuantity * _times);

  /// Adds the specified entry to this entry.
  void absorbEntry(HistoryEntry entry) {
    if (entry._quantity == null || entry._moreThanQuantity) {
      _moreThanQuantity = true;
    }
    if (entry._quantity != null) {
      _quantity = (_quantity ?? 0) + entry._quantity!;
    }

    _times += entry._times;
    notifyListeners();
  }

  /// Returns the times held by this entry.
  int get times => _times;

  /// Sets the quantity.
  set times(int times) {
    _times = times;
    notifyListeners();
  }

  /// Returns whether this beer has been drunk more than the displayed quantity.
  bool get moreThanQuantity => _moreThanQuantity;

  /// Sets whether this beer has been drunk more than the displayed quantity.
  set moreThanQuantity(bool moreThanQuantity) {
    _moreThanQuantity = moreThanQuantity;
    notifyListeners();
  }

  /// Updates the moreThanQuantity field.
  void updateMoreThanQuantity({bool notify = true}) {
    _moreThanQuantity = _quantity == null;
    if (notify) {
      notifyListeners();
    }
  }

  /// Converts this object to a JSON map.
  Map<String, dynamic> toJson() => {
        'beer': _beerUuid,
        'quantity': _quantity,
        'times': _times,
        'moreThanQuantity': _moreThanQuantity,
      };
}
