import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';

/// Allows to edit a rating.
class RatingFormField extends FormField<double> {
  /// Creates a new rating form field instance.
  RatingFormField({
    super.key,
    super.validator,
    super.onSaved,
    super.initialValue,
    bool readOnly = false,
  }) : super(
          builder: (FormFieldState<double> state) => readOnly
              ? RatingBar.readOnly(
                  initialRating: initialValue ?? 0,
                  size: 40,
                  filledIcon: Icons.star,
                  halfFilledIcon: Icons.star_half_outlined,
                  emptyIcon: Icons.star_border,
                  isHalfAllowed: true,
                )
              : RatingBar(
                  initialRating: initialValue ?? 0,
                  size: 40,
                  filledIcon: Icons.star,
                  halfFilledIcon: Icons.star_half_outlined,
                  emptyIcon: Icons.star_border,
                  onRatingChanged: (rating) => state.didChange(rating),
                  isHalfAllowed: true,
                ),
        );
}
