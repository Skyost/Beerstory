import 'dart:io';

import 'package:beerstory/model/repository.dart';
import 'package:beerstory/utils/compare_fields.dart';
import 'package:beerstory/utils/searchable.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Represents a beer.
class Beer extends RepositoryObject with HasName, Searchable implements Comparable<Beer> {
  @override
  final String name;

  /// The beer image.
  final String? image;

  /// The beer tags.
  final List<String> _tags;

  /// The beer degrees.
  final double? degrees;

  /// The beer rating.
  final double? rating;

  /// Additional comment on the beer.
  final String? comment;

  /// Creates a new beer instance.
  Beer({
    super.uuid,
    this.name = '',
    this.image,
    List<String> tags = const [],
    this.degrees,
    this.rating,
    this.comment,
  }) : _tags = List.of(tags);

  /// Returns the beer tags.
  List<String> get tags => List.of(_tags);

  @override
  bool operator ==(Object other) {
    if (other is! Beer) {
      return super == other;
    }
    return identical(this, other) ||
        (uuid == other.uuid && name == other.name && image == other.image && listEquals(_tags, other._tags) && degrees == other.degrees && rating == other.rating && comment == other.comment);
  }

  @override
  int get hashCode => Object.hash(uuid, name, image, tags, degrees, rating, comment);

  @override
  Beer copyWith({
    String? uuid,
    String? name,
    String? image,
    List<String>? tags,
    double? degrees,
    double? rating,
    String? comment,
  }) => Beer(
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    image: image ?? this.image,
    tags: tags ?? _tags,
    degrees: degrees ?? this.degrees,
    rating: rating ?? this.rating,
    comment: comment ?? this.comment,
  );

  /// Overwrites the [Beer.image] field.
  Beer overwriteImage({String? image}) => Beer(
    uuid: uuid,
    name: name,
    image: image,
    tags: _tags,
    degrees: degrees,
    rating: rating,
    comment: comment,
  );

  /// Overwrites the [Beer.degrees] field.
  Beer overwriteDegrees({double? degrees}) => Beer(
    uuid: uuid,
    name: name,
    image: image,
    tags: _tags,
    degrees: degrees,
    rating: rating,
    comment: comment,
  );

  /// Overwrites the [Beer.rating] field.
  Beer overwriteRating({double? rating}) => Beer(
    uuid: uuid,
    name: name,
    image: image,
    tags: _tags,
    degrees: degrees,
    rating: rating,
    comment: comment,
  );

  /// Overwrites the [Beer.comment] field.
  Beer overwriteComment({String? comment}) => Beer(
    uuid: uuid,
    name: name,
    image: image,
    tags: _tags,
    degrees: degrees,
    rating: rating,
    comment: comment,
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
    if (comment != null) comment!,
  ];
}

/// Contains some methods to work with beers images.
class BeerImage {
  /// Returns the beer image path.
  static Future<Directory> getImagesTargetDirectory({
    bool create = true,
  }) async => Directory(
    path.join((await getApplicationSupportDirectory()).path, 'images'),
  );

  /// Copies the image to the target directory and returns the path.
  static Future<String?> copyImage({
    required String originalFilePath,
    required String filenamePrefix,
    String source = 'manual',
  }) async {
    try {
      Uri uri = Uri.parse(originalFilePath);
      String extension = path.extension(uri.pathSegments.last);
      Directory directory = await getImagesTargetDirectory();
      String filename = filenamePrefix;
      if (source == 'manual') {
        filename += '-${DateTime.now().millisecondsSinceEpoch}';
      }
      File file = File(
        path.join(directory.path, source, '$filename$extension'),
      );
      file.parent.createSync(recursive: true);
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        file.writeAsBytesSync((await http.get(uri)).bodyBytes);
      } else {
        File originalFile = File(uri.path);
        if (!originalFile.existsSync()) {
          return null;
        }
        originalFile.copySync(file.path);
      }
      return file.path;
    } catch (ex, stackTrace) {
      printError(ex, stackTrace);
    }
    return null;
  }
}
