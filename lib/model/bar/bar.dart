import 'package:beerstory/model/repository.dart';
import 'package:beerstory/utils/compare_fields.dart';
import 'package:beerstory/utils/searchable.dart';

/// Represents a bar.
class Bar extends RepositoryObject with HasName, Searchable implements Comparable<Bar> {
  @override
  final String name;

  /// The bar address.
  final String? address;

  /// Additional comment on the bar.
  final String? comment;

  /// Creates a new bar instance.
  Bar({
    super.uuid,
    this.name = '',
    this.address,
    this.comment,
  });

  @override
  bool operator ==(Object other) {
    if (other is! Bar) {
      return super == other;
    }
    return identical(this, other) || (uuid == other.uuid && name == other.name && address == other.address && comment == other.comment);
  }

  @override
  int get hashCode => Object.hash(uuid, name, address, comment);

  @override
  Bar copyWith({
    String? uuid,
    String? name,
    String? address,
    String? comment,
  }) => Bar(
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    address: address ?? this.address,
    comment: comment ?? this.comment,
  );

  /// Overwrites the [Bar.address] field.
  Bar overwriteAddress({String? address}) => Bar(
    uuid: uuid,
    name: name,
    address: address,
    comment: comment,
  );

  /// Overwrites the [Bar.comment] field.
  Bar overwriteComment({String? comment}) => Bar(
    uuid: uuid,
    name: name,
    address: address,
    comment: comment,
  );

  @override
  int compareTo(Bar other) => compareAccordingToFields<Bar>(
    this,
    other,
    (bar) => [
      bar.name,
      bar.address,
      bar.uuid,
    ],
  );

  @override
  List<String> get searchTerms => [
    name,
    if (address != null) address!,
    if (comment != null) comment!,
  ];
}
