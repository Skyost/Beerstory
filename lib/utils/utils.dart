import 'package:beerstory/i18n/translations.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Allows to check if a string is numeric.
extension StringUtils on String {
  /// Checks whether the current string is numeric.
  bool get isNumeric => double.tryParse(this) != null;

  /// Checks whether the current string is empty, and if so, returns a `null` object.
  String? get nullIfEmpty => trim().isEmpty ? null : trim();
}

/// Checks whether a string is empty, and if so, returns an error message.
String? emptyStringValidator(String? value) {
  if (value?.nullIfEmpty == null) {
    return translations.error.empty;
  }
  return null;
}

/// Allows to get the dark variant of the primary color of the current color scheme.
extension PrimaryDark on ColorScheme {
  /// Returns the dark primary color.
  Color get darkPrimary => (primary as MaterialColor)[700]!;
}

/// Allows to check if a number is an integer.
extension IntegerUtils on num {
  /// Returns whether this number is an integer.
  bool get isInteger => this is int || this == truncateToDouble();

  /// Returns an integer if possible.
  num toIntIfPossible() => isInteger ? toInt() : this;
}

/// Contains some useful iterable methods.
extension IterableUtils<T> on Iterable<T> {
  /// Returns the first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

/// Contains some useful date time methods.
extension DateTimeUtils on DateTime {
  /// Returns the date without the time.
  DateTime withoutTime() => DateTime(year, month, day);
}

/// Prints an error.
void printError(Object error, StackTrace? stackTrace) {
  if (kDebugMode) {
    print(error);
    if (stackTrace != null) {
      print(stackTrace);
    }
  }
}
/// Allows to check if a type is a subtype of another.
bool isSubtype<S, T>() => <S>[] is List<T>;
