import 'package:beerstory/model/repository.dart';
import 'package:beerstory/utils/compare_fields.dart';
import 'package:beerstory/utils/searchable.dart';

/// Represents a bar.
class Bar extends RepositoryObject with HasName, Searchable implements Comparable<Bar> {
  @override
  final String name;

  /// The bar address.
  final String? address;

  /// Additional comments on the bar.
  final String? comments;

  /// Creates a new bar instance.
  Bar({
    super.uuid,
    this.name = '',
    this.address,
    this.comments,
  });

  @override
  bool operator ==(Object other) {
    if (other is! Bar) {
      return super == other;
    }
    return identical(this, other) || (uuid == other.uuid && name == other.name && address == other.address && comments == other.comments);
  }

  @override
  int get hashCode => Object.hash(uuid, name, address, comments);

  @override
  Bar copyWith({
    String? uuid,
    String? name,
    String? address,
    String? comments,
  }) => Bar(
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    address: address ?? this.address,
    comments: comments ?? this.comments,
  );

  /// Overwrites the [Bar.address] field.
  Bar overwriteAddress({String? address}) => Bar(
    uuid: uuid,
    name: name,
    address: address,
    comments: comments,
  );

  /// Overwrites the [Bar.comments] field.
  Bar overwriteComments({String? comments}) => Bar(
    uuid: uuid,
    name: name,
    address: address,
    comments: comments,
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
    if (comments != null) comments!,
  ];
}
