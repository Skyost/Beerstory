import 'dart:io';

import 'package:beerstory/model/repository.dart';
import 'package:beerstory/utils/compare_fields.dart';
import 'package:beerstory/utils/searchable.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Represents a beer.
class Beer extends RepositoryObject with Searchable implements Comparable<Beer> {
  /// The beer name.
  final String name;

  /// The beer image.
  final String? image;

  /// The beer tags.
  final List<String> _tags;

  /// The beer degrees.
  final double? degrees;

  /// The beer rating.
  final double? rating;

  /// Creates a new beer instance.
  Beer({
    super.uuid,
    this.name = '',
    this.image,
    List<String> tags = const [],
    this.degrees,
    this.rating,
  }) : _tags = List.of(tags);

  /// Returns the beer tags.
  List<String> get tags => List.of(_tags);

  @override
  bool operator ==(Object other) {
    if (other is! Beer) {
      return super == other;
    }
    return identical(this, other) || (uuid == other.uuid && name == other.name && image == other.image && _tags == other._tags && degrees == other.degrees && rating == other.rating);
  }

  @override
  int get hashCode => Object.hash(uuid, name, image, tags, degrees, rating);

  @override
  Beer copyWith({
    String? uuid,
    String? name,
    String? image,
    List<String>? tags,
    double? degrees,
    double? rating,
  }) =>
      Beer(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        image: image ?? this.image,
        tags: tags ?? _tags,
        degrees: degrees ?? this.degrees,
        rating: rating ?? this.rating,
      );

  /// Overwrites the [Beer.image] field.
  Beer overwriteImage({String? image}) => Beer(
        uuid: uuid,
        name: name,
        image: image,
        tags: _tags,
        degrees: degrees,
        rating: rating,
      );

  /// Overwrites the [Beer.degrees] field.
  Beer overwriteDegrees({double? degrees}) => Beer(
        uuid: uuid,
        name: name,
        image: image,
        tags: _tags,
        degrees: degrees,
        rating: rating,
      );

  /// Overwrites the [Beer.rating] field.
  Beer overwriteRating({double? rating}) => Beer(
        uuid: uuid,
        name: name,
        image: image,
        tags: _tags,
        degrees: degrees,
        rating: rating,
      );

  @override
  int compareTo(Beer other) => compareAccordingToFields<Beer>(
        this,
        other,
        (beer) => [
          beer.name,
          beer.rating,
          beer.degrees,
          beer.uuid,
        ],
      );

  @override
  List<String> get searchTerms => [
        name,
        ..._tags,
      ];

  /// Returns the beer image path.
  static Future<Directory> getImagesTargetDirectory({bool create = true}) async => Directory(path.join((await getApplicationSupportDirectory()).path, 'images'));
}
