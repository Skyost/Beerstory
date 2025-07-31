import 'package:beerstory/i18n/translations.g.dart';
import 'package:intl/intl.dart' as intl;

/// Allows to format numbers.
class NumberFormat {
  /// The decimal formatter.
  static intl.NumberFormat get _decimalFormatter => intl.NumberFormat.decimalPattern(translations.$meta.locale.languageCode);

  /// The currency formatter.
  static intl.NumberFormat get _currencyFormatter => intl.NumberFormat.simpleCurrency(
    locale: translations.$meta.locale.languageCode,
  );

  /// Formats a number.
  static String formatDouble(double number) => _decimalFormatter.format(number);

  /// Formats a price.
  static String formatPrice(double price) => _currencyFormatter.format(price);

  /// Tries to parse a number.
  static double? tryParseDouble(String? text) => _decimalFormatter.tryParse(text ?? '')?.toDouble();
}
