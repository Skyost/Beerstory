import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'history.g.dart';

/// Represents a list of history entries associated with a date.
@HiveType(typeId: 3)
class OldHistoryEntries extends HiveObject {
  /// The key date formatter.
  static DateFormat formatter = DateFormat('yyyy-MM-dd');

  /// The entries list.
  @HiveField(0)
  List<OldHistoryEntry>? entries;

  /// Creates a new history entries instance.
  OldHistoryEntries({
    required this.entries,
  });
}

/// Represents an history entry.
@HiveType(typeId: 4)
class OldHistoryEntry extends HiveObject {
  /// The beer id.
  @HiveField(0)
  int beerId;

  /// The quantity.
  @HiveField(1)
  double? _quantity;

  /// The number of times this beer has been drank.
  @HiveField(2)
  int times;

  /// Whether this is more than the current quantity.
  @HiveField(3)
  late bool moreThanQuantity;

  /// Creates a new history entry instance.
  OldHistoryEntry({
    required this.beerId,
    double? quantity,
    this.times = 1,
  }) {
    _quantity = quantity;
    updateMoreThanQuantity();
  }

  /// Returns the quantity.
  double? get quantity => _quantity;

  /// Sets the quantity.
  set quantity(double? quantity) {
    _quantity = quantity;
    updateMoreThanQuantity();
  }

  /// Updates the moreThanQuantity field.
  void updateMoreThanQuantity() => moreThanQuantity = _quantity == null;
}
