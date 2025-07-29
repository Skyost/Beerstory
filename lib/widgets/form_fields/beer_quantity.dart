// ignore_for_file: prefer_const_constructors

import 'package:beerstory/spacing.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// The beer quantity form field.
class BeerQuantityFormField extends FormField<BeerQuantity> {
  /// Creates a new beer quantity form field instance.
  BeerQuantityFormField({
    super.key,
    Widget? label,
    required Widget title,
    super.onSaved,
    super.validator,
    super.initialValue = const EmptyBeerQuantity(),
    String? customQuantityHint,
    required String Function(BeerQuantity) getQuantityTitle,
  }) : super(
         builder: (state) => Column(
           spacing: kSpace,
           children: [
             FSelectMenuTile<BeerQuantity>(
               validator: (quantities) => validator?.call(quantities?.firstOrNull),
               prefix: Icon(FIcons.rotateCcw),
               label: label,
               title: title,
               initialValue: initialValue,
               forceErrorText: state.errorText,
               detailsBuilder: (_, values, _) {
                 BeerQuantity? quantity = values.firstOrNull;
                 return quantity == null ? SizedBox.shrink() : Text(getQuantityTitle(quantity));
               },
               menu: [
                 for (BeerQuantity quantity in const [
                   EmptyBeerQuantity(),
                   BottleBeerQuantity(),
                   HalfPintBeerQuantity(),
                   PintBeerQuantity(),
                   CustomBeerQuantity(),
                 ])
                   FSelectTile(
                     value: quantity,
                     title: Text(getQuantityTitle(quantity)),
                   ),
               ],
               onChange: (value) {
                 state.didChange(value.firstOrNull);
               },
             ),
             if (state.value is CustomBeerQuantity)
               FTextFormField(
                 hint: customQuantityHint,
                 initialText: state.value?.value?.toString() ?? '',
                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
                 onChange: (value) {
                   double? quantity = double.tryParse(value);
                   if (quantity != null && quantity < 0) {
                     quantity = null;
                   }
                   state.didChange(CustomBeerQuantity(value: quantity));
                 },
               ),
           ],
         ),
       );
}

/// Represents the beer quantity.
sealed class BeerQuantity {
  /// The quantity value.
  final double? value;

  /// Creates a new beer quantity instance.
  const BeerQuantity._({
    this.value,
  });

  /// Creates a new beer quantity instance.
  factory BeerQuantity({
    double? value,
  }) => switch (value) {
    null => const EmptyBeerQuantity(),
    33 => const BottleBeerQuantity(),
    50 => const HalfPintBeerQuantity(),
    100 => const PintBeerQuantity(),
    _ => CustomBeerQuantity(value: value),
  };

  /// Copies the current beer quantity instance.
  BeerQuantity copyWith({
    double? value,
  });
}

/// Represents an empty beer quantity.
class EmptyBeerQuantity extends BeerQuantity {
  /// Creates a new empty beer quantity instance.
  const EmptyBeerQuantity() : super._();

  @override
  BeerQuantity copyWith({
    double? value,
  }) => EmptyBeerQuantity();
}

/// Represents a bottle beer quantity.
class BottleBeerQuantity extends BeerQuantity {
  /// The bottle quantity.
  static const double quantity = 33;

  /// Creates a new bottle beer quantity instance.
  const BottleBeerQuantity()
    : super._(
        value: quantity,
      );

  @override
  BeerQuantity copyWith({
    double? value,
  }) => BottleBeerQuantity();
}

/// Represents a half pint beer quantity.
class HalfPintBeerQuantity extends BeerQuantity {
  /// The half pint quantity.
  static const double quantity = 50;

  /// Creates a new half pint beer quantity instance.
  const HalfPintBeerQuantity()
    : super._(
        value: quantity,
      );

  @override
  BeerQuantity copyWith({
    double? value,
  }) => HalfPintBeerQuantity();
}

/// Represents a pint beer quantity.
class PintBeerQuantity extends BeerQuantity {
  /// The pint quantity.
  static const double quantity = 100;

  /// Creates a new pint beer quantity instance.
  const PintBeerQuantity()
    : super._(
        value: quantity,
      );

  @override
  BeerQuantity copyWith({
    double? value,
  }) => PintBeerQuantity();
}

/// Represents a custom beer quantity.
class CustomBeerQuantity extends BeerQuantity {
  /// Creates a new custom beer quantity instance.
  const CustomBeerQuantity({
    super.value,
  }) : super._();

  @override
  BeerQuantity copyWith({
    double? value,
  }) => CustomBeerQuantity(value: value);
}
