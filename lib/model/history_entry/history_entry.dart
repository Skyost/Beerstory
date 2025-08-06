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

  /// Additional comments on the history entry.
  final String? comments;

  /// Creates a new history entry instance.
  HistoryEntry({
    super.uuid,
    DateTime? date,
    required this.beerUuid,
    this.quantity,
    this.times = 1,
    this.moreThanQuantity = false,
    this.comments,
  }) : date = date ?? DateTime.now().withoutTime();

  @override
  bool operator ==(Object other) {
    if (other is! HistoryEntry) {
      return super == other;
    }
    return identical(this, other) ||
        (uuid == other.uuid &&
            date == other.date &&
            beerUuid == other.beerUuid &&
            quantity == other.quantity &&
            times == other.times &&
            moreThanQuantity == other.moreThanQuantity &&
            comments == other.comments);
  }

  @override
  int get hashCode => Object.hash(uuid, date, beerUuid, quantity, times, moreThanQuantity, comments);

  @override
  HistoryEntry copyWith({
    String? uuid,
    DateTime? date,
    String? beerUuid,
    double? quantity,
    int? times,
    bool? moreThanQuantity,
    String? comments,
  }) => HistoryEntry(
    uuid: uuid ?? this.uuid,
    date: date ?? this.date,
    beerUuid: beerUuid ?? this.beerUuid,
    quantity: quantity ?? this.quantity,
    times: times ?? this.times,
    moreThanQuantity: moreThanQuantity ?? this.moreThanQuantity,
    comments: comments ?? this.comments,
  );

  /// Overwrites the [HistoryEntry.quantity] field.
  HistoryEntry overwriteQuantity({double? quantity}) => HistoryEntry(
    uuid: uuid,
    date: date,
    beerUuid: beerUuid,
    quantity: quantity,
    times: times,
    moreThanQuantity: moreThanQuantity,
    comments: comments,
  );

  /// Overwrites the [HistoryEntry.comments] field.
  HistoryEntry overwriteComments({String? comments}) => HistoryEntry(
    uuid: uuid,
    date: date,
    beerUuid: beerUuid,
    quantity: quantity,
    times: times,
    moreThanQuantity: moreThanQuantity,
    comments: comments,
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
  HistoryEntry absorbEntry(HistoryEntry historyEntry) {
    AbsorbResult result = AbsorbResult.fromHistoryEntry(historyEntry: this)..absorb(historyEntry);
    return copyWith(
      moreThanQuantity: result.moreThanQuantity,
      quantity: result.quantity,
      times: result.times,
    );
  }
}

/// Represents the result of an absorb.
class AbsorbResult {
  /// The quantity.
  double? quantity;

  /// The number of times this beer has been drank.
  int times;

  /// Whether this is more than the current [quantity].
  bool moreThanQuantity;

  /// Creates a new absorb result instance.
  AbsorbResult({
    this.quantity,
    this.times = 1,
    this.moreThanQuantity = false,
  });

  /// Creates a new absorb result instance from a [historyEntry].
  AbsorbResult.fromHistoryEntry({
    required HistoryEntry historyEntry,
  }) : this(
         quantity: historyEntry.quantity,
         times: historyEntry.times,
         moreThanQuantity: historyEntry.moreThanQuantity,
       );

  /// Absorbs the specified [historyEntry].
  void absorb(HistoryEntry historyEntry) {
    if (historyEntry.quantity == null || historyEntry.moreThanQuantity) {
      moreThanQuantity = true;
    }

    if (historyEntry.quantity != null) {
      quantity = (quantity ?? 0) + historyEntry.quantity!;
    }

    times += historyEntry.times;
  }

  /// Calculates the true quantity drunk.
  double? get trueQuantity => quantity == null ? null : (quantity! * times);
}
