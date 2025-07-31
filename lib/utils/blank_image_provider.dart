import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// An [ImageProvider] that doesn't load anything.
class BlankImageProvider extends ImageProvider<BlankImageProvider> {
  /// Creates a new blank image provider.
  const BlankImageProvider();

  @override
  Future<BlankImageProvider> obtainKey(ImageConfiguration configuration) => SynchronousFuture<BlankImageProvider>(this);
}
