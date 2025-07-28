import 'package:beerstory/model/repository.dart';
import 'package:beerstory/utils/compare_fields.dart';
import 'package:beerstory/utils/utils.dart';

/// Represents a history entry.
class HistoryEntry extends RepositoryObject implements Comparable<HistoryEntry> {
  /// The date.
  final DateTime date;

  /// The beer uuid.
  final String beerUuid;

  /// The quantity.
  final double? quantity;

  /// The number of times this beer has been drank.
  final int times;

  /// Whether this is more than the current [quantity].
  final bool moreThanQuantity;

  /// Creates a new history entry instance.
  HistoryEntry({
    super.uuid,
    DateTime? date,
    required this.beerUuid,
    this.quantity,
    this.times = 1,
    this.moreThanQuantity = false,
  }) : date = date ?? DateTime.now().withoutTime();

  @override
  bool operator ==(Object other) {
    if (other is! HistoryEntry) {
      return super == other;
    }
    return identical(this, other) ||
        (uuid == other.uuid && date == other.date && beerUuid == other.beerUuid && quantity == other.quantity && times == other.times && moreThanQuantity == other.moreThanQuantity);
  }

  @override
  int get hashCode => Object.hash(uuid, date, beerUuid, quantity, times, moreThanQuantity);

  @override
  HistoryEntry copyWith({
    String? uuid,
    DateTime? date,
    String? beerUuid,
    double? quantity,
    int? times,
    bool? moreThanQuantity,
  }) =>
      HistoryEntry(
        uuid: uuid ?? this.uuid,
        date: date ?? this.date,
        beerUuid: beerUuid ?? this.beerUuid,
        quantity: quantity ?? this.quantity,
        times: times ?? this.times,
        moreThanQuantity: moreThanQuantity ?? this.moreThanQuantity,
      );

  /// Overwrites the [HistoryEntry.quantity] field.
  HistoryEntry overwriteQuantity({double? quantity}) => HistoryEntry(
        uuid: uuid,
        date: date,
        beerUuid: beerUuid,
        quantity: quantity,
        times: times,
        moreThanQuantity: moreThanQuantity,
      );

  @override
  int compareTo(HistoryEntry other) => compareAccordingToFields<HistoryEntry>(
        this,
        other,
        (entry) => [
          entry.date,
          entry.times,
          entry.quantity,
          entry.uuid,
        ],
      );

  /// Calculates the true quantity drunk.
  double? calculateTrueQuantity(double? rawQuantity) => rawQuantity == null ? null : (rawQuantity * times);

  /// Adds the specified entry to this entry.
  HistoryEntry absorbEntry(HistoryEntry entry) {
    bool? moreThanQuantity;
    if (entry.quantity == null || entry.moreThanQuantity) {
      moreThanQuantity = true;
    }

    double? quantity;
    if (entry.quantity != null) {
      quantity = (quantity ?? 0) + entry.quantity!;
    }

    int times = this.times + entry.times;
    return copyWith(
      moreThanQuantity: moreThanQuantity,
      quantity: quantity,
      times: times,
    );
  }
}
