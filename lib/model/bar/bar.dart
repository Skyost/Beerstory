import 'package:beerstory/model/repository.dart';
import 'package:beerstory/utils/compare_fields.dart';
import 'package:beerstory/utils/searchable.dart';

/// Represents a bar.
class Bar extends RepositoryObject with Searchable implements Comparable<Bar> {
  /// The bar name.
  final String name;

  /// The bar address.
  final String? address;

  /// Creates a new bar instance.
  Bar({
    super.uuid,
    this.name = '',
    this.address,
  });

  @override
  bool operator ==(Object other) {
    if (other is! Bar) {
      return super == other;
    }
    return identical(this, other) || (uuid == other.uuid && name == other.name && address == other.address);
  }

  @override
  int get hashCode => Object.hash(uuid, name, address);

  @override
  Bar copyWith({
    String? uuid,
    String? name,
    String? address,
  }) =>
      Bar(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        address: address ?? this.address,
      );

  /// Overwrites the [Bar.address] field.
  Bar overwriteAddress({String? address}) => Bar(
        uuid: uuid,
        name: name,
        address: address,
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
      ];
}
