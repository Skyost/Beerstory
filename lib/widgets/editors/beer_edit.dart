// ignore_for_file: prefer_const_constructors

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:beerstory/widgets/form_fields/beer_image.dart';
import 'package:beerstory/widgets/form_fields/rating.dart';
import 'package:beerstory/widgets/form_fields/tags.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// The add beer dialog.
class AddBeerDialog extends FormDialog<Beer> {
  /// The edit beer dialog internal constructor.
  const AddBeerDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<Beer, AddBeerDialog> createState() => _AddBeerDialogState();

  /// Shows a new beer editor.
  static Future<Beer?> show({
    required BuildContext context,
    Beer? beer,
  }) => showFDialog<Beer>(
    context: context,
    builder: (context, style, animation) => AddBeerDialog._(
      object: beer ?? Beer(),
      style: style.call,
      animation: animation,
    ),
  );
}

/// The add beer dialog state.
class _AddBeerDialogState extends FormDialogState<Beer, AddBeerDialog> {
  /// The current beer instance.
  late Beer beer = widget.object.copyWith();

  @override
  List<Widget> createChildren(BuildContext context) => [
    Padding(
      padding: const EdgeInsets.only(bottom: kSpace * 2),
      child: Center(
        child: BeerImageFormField(
          initialValue: beer.image,
          beerUuid: beer.uuid,
          beerName: beer.name,
          onSaved: (value) => beer = beer.overwriteImage(
            image: value,
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(bottom: kSpace),
      child: FTextFormField(
        label: Text(translations.beers.dialog.name.label),
        hint: translations.beers.dialog.name.hint,
        initialText: beer.name,
        validator: emptyStringValidator,
        onSaved: (value) => beer = beer.copyWith(
          name: value?.trim(),
        ),
      ),
    ),
    Padding(
      padding: EdgeInsets.only(bottom: kSpace * 2),
      child: RatingFormField(
        label: Text(translations.beers.dialog.rating.label),
        initialValue: beer.rating,
        size: 50,
        onSaved: (value) => beer = beer.overwriteRating(rating: (value ?? 0) <= 0 ? null : value),
      ),
    ),
  ];

  @override
  Beer? onSaved() => beer;
}

/// Allows to edit a beer name.
class BeerNameEditorDialog extends FormDialog<String> {
  /// The beer name editor internal constructor.
  const BeerNameEditorDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<String, BeerNameEditorDialog> createState() => _BeerNameEditorDialogState();

  /// Shows a new beer name editor.
  static Future<String?> show({
    required BuildContext context,
    required String beerName,
  }) => showFDialog<String>(
    context: context,
    builder: (context, style, animation) => BeerNameEditorDialog._(
      object: beerName,
      style: style.call,
      animation: animation,
    ),
  );
}

/// The beer name editor dialog state.
class _BeerNameEditorDialogState extends FormDialogState<String, BeerNameEditorDialog> {
  /// The current beer name.
  late String? beerName = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    Padding(
      padding: const EdgeInsets.only(bottom: kSpace),
      child: FTextFormField(
        label: Text(translations.beers.dialog.name.label),
        hint: translations.beers.dialog.name.hint,
        initialText: beerName,
        validator: emptyStringValidator,
        onSaved: (value) => beerName = value?.nullIfEmpty,
      ),
    ),
  ];

  @override
  String? onSaved() => beerName;
}

/// Allows to edit a beer degrees.
class BeerDegreesEditorDialog extends FormDialog<double?> {
  /// The beer degrees editor internal constructor.
  const BeerDegreesEditorDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<double?, BeerDegreesEditorDialog> createState() => _BeerDegreesEditorDialogState();

  /// Shows a new beer degrees editor.
  static Future<double?> show({
    required BuildContext context,
    required double? beerDegrees,
  }) => showFDialog<double?>(
    context: context,
    builder: (context, style, animation) => BeerDegreesEditorDialog._(
      object: beerDegrees,
      style: style.call,
      animation: animation,
    ),
  );
}

/// The beer degrees editor dialog state.
class _BeerDegreesEditorDialogState extends FormDialogState<double?, BeerDegreesEditorDialog> {
  /// The current beer degrees.
  late double? beerDegrees = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    Padding(
      padding: const EdgeInsets.only(bottom: kSpace),
      child: FTextFormField(
        label: Text(translations.beers.dialog.degrees.label),
        hint: translations.beers.dialog.degrees.hint,
        initialText: (beerDegrees?.toIntIfPossible() ?? '').toString(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onSaved: (value) => beerDegrees = double.tryParse(value ?? ''),
      ),
    ),
  ];

  @override
  double? onSaved() => beerDegrees;
}

/// Allows to edit a beer rating.
class BeerRatingEditorDialog extends FormDialog<double?> {
  /// The beer rating editor internal constructor.
  const BeerRatingEditorDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<double?, BeerRatingEditorDialog> createState() => _BeerRatingEditorDialogState();

  /// Shows a new beer rating editor.
  static Future<double?> show({
    required BuildContext context,
    required double? beerRating,
  }) => showFDialog<double?>(
    context: context,
    builder: (context, style, animation) => BeerRatingEditorDialog._(
      object: beerRating,
      style: style.call,
      animation: animation,
    ),
  );
}

/// The beer rating editor dialog state.
class _BeerRatingEditorDialogState extends FormDialogState<double?, BeerRatingEditorDialog> {
  /// The current beer rating.
  late double? beerRating = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    RatingFormField(
      label: Text(translations.beers.dialog.rating.label),
      initialValue: beerRating,
      size: 50,
      onSaved: (value) => beerRating = (value ?? 0) <= 0 ? null : value,
    ),
  ];

  @override
  double? onSaved() => beerRating;
}

/// Allows to edit a beer tags.
class BeerTagsEditorDialog extends FormDialog<List<String>?> {
  /// The beer tags editor internal constructor.
  const BeerTagsEditorDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<List<String>?, BeerTagsEditorDialog> createState() => _BeerTagsEditorDialogState();

  /// Shows a new beer tags editor.
  static Future<List<String>?> show({
    required BuildContext context,
    required List<String> beerTags,
  }) => showFDialog<List<String>?>(
    context: context,
    builder: (context, style, animation) => BeerTagsEditorDialog._(
      object: beerTags,
      style: style.call,
      animation: animation,
    ),
  );
}

/// The beer tags editor dialog state.
class _BeerTagsEditorDialogState extends FormDialogState<List<String>?, BeerTagsEditorDialog> {
  /// The current beer tags.
  late List<String>? beerTags = widget.object;

  /// The add form focus node.
  final FocusNode addFormFocusNode = FocusNode();

  /// The add form controller.
  final TextEditingController addFormController = TextEditingController();

  @override
  List<Widget> createChildren(BuildContext context) => [
    TagsFormField(
      initialValue: beerTags,
      label: Text(translations.beers.dialog.tags.label),
      addFormHint: translations.beers.dialog.tags.hint,
      addFormFocusNode: addFormFocusNode,
      addFormController: addFormController,
      tagDeleteIcon: FIcons.delete,
      onSaved: (value) => beerTags = value,
    ),
  ];

  @override
  List<String>? onSaved() => beerTags;

  @override
  void dispose() {
    addFormFocusNode.dispose();
    addFormController.dispose();
    super.dispose();
  }
}
