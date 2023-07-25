import 'dart:io';

import 'package:flutter/material.dart';

/// Allows to check if a string is numeric.
extension Numeric on String {
  /// Checks whether the current string is numeric.
  bool get isNumeric => double.tryParse(this) != null;
}

/// Allows to move a file.
extension Move on File {
  /// Moves this file to another path.
  Future<File> move(String to) async {
    try {
      return await rename(to);
    } on FileSystemException catch (_) {
      final newFile = await copy(to);
      await delete();
      return newFile;
    }
  }
}

/// Allows to get the dark variant of the primary color of the current color scheme.
extension PrimaryDark on ColorScheme {
  /// Returns the dark primary color.
  Color get darkPrimary => (primary as MaterialColor)[700]!;
}
