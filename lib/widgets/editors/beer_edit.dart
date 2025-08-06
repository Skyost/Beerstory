import 'dart:io';
import 'dart:math' as math;

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/format.dart';
import 'package:beerstory/utils/platform.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:beerstory/widgets/smooth_star_rating.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';

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
  static Future<FormDialogResult<Beer>> show({
    required BuildContext context,
    Beer? beer,
  }) => FormDialog.show(
    context: context,
    object: beer ?? Beer(),
    builder: AddBeerDialog._,
  );
}

/// The add beer dialog state.
class _AddBeerDialogState extends FormDialogState<Beer, AddBeerDialog> {
  /// The current beer instance.
  late Beer beer = widget.object.copyWith();

  /// The beer name.
  late String beerName = beer.name;

  /// The add form focus node.
  final FocusNode addFormFocusNode = FocusNode();

  /// The add form controller.
  final TextEditingController addFormController = TextEditingController();

  @override
  List<Widget> createChildren(BuildContext context) => [
    Padding(
      padding: const EdgeInsets.only(bottom: kSpace),
      child: Center(
        child: BeerImageFormField(
          initialValue: beer.image,
          beerUuid: beer.uuid,
          beerName: beerName,
          onSaved: (value) => beer = beer.overwriteImage(
            image: value,
          ),
        ),
      ),
    ),
    _BeerNameFormField(
      initialText: beer.name,
      onChange: (value) {
        setState(() => beerName = value);
      },
      onSaved: (value) => beer = beer.copyWith(
        name: value?.trim(),
      ),
    ),
    _BeerRatingFormField(
      initialValue: beer.rating,
      onSaved: (value) => beer = beer.overwriteRating(
        rating: value,
      ),
    ),
    _BeerDegreesFormField(
      initialValue: beer.degrees,
      onSaved: (value) => beer = beer.overwriteDegrees(
        degrees: value,
      ),
    ),
    _BeerTagsFormField(
      initialValue: beer.tags,
      addFormFocusNode: addFormFocusNode,
      addFormController: addFormController,
      onSaved: (value) => beer = beer.copyWith(
        tags: value,
      ),
    ),
  ];

  @override
  Beer? onSaved() => beer;

  @override
  void dispose() {
    addFormFocusNode.dispose();
    addFormController.dispose();
    super.dispose();
  }
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
  static Future<FormDialogResult<String>> show({
    required BuildContext context,
    required String name,
  }) => FormDialog.show(
    context: context,
    object: name,
    builder: BeerNameEditorDialog._,
  );
}

/// The beer name editor dialog state.
class _BeerNameEditorDialogState extends FormDialogState<String, BeerNameEditorDialog> {
  /// The current beer name.
  late String? name = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    _BeerNameFormField(
      initialText: name,
      onSaved: (value) => name = value?.trimOrNullIfEmpty,
    ),
  ];

  @override
  String? onSaved() => name;
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
  static Future<FormDialogResult<double?>> show({
    required BuildContext context,
    required double? degrees,
  }) => FormDialog.show(
    context: context,
    object: degrees,
    builder: BeerDegreesEditorDialog._,
  );
}

/// The beer degrees editor dialog state.
class _BeerDegreesEditorDialogState extends FormDialogState<double?, BeerDegreesEditorDialog> {
  /// The current beer degrees.
  late double? degrees = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    _BeerDegreesFormField(
      initialValue: degrees,
      onSaved: (value) => degrees = value,
    ),
  ];

  @override
  double? onSaved() => degrees;
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
  static Future<FormDialogResult<double?>> show({
    required BuildContext context,
    required double? rating,
  }) => FormDialog.show(
    context: context,
    object: rating,
    builder: BeerRatingEditorDialog._,
  );
}

/// The beer rating editor dialog state.
class _BeerRatingEditorDialogState extends FormDialogState<double?, BeerRatingEditorDialog> {
  /// The current beer rating.
  late double? rating = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    _BeerRatingFormField(
      initialValue: rating,
      onSaved: (value) => rating = value,
    ),
  ];

  @override
  double? onSaved() => rating;
}

/// Allows to edit a beer tags.
class BeerTagsEditorDialog extends FormDialog<List<String>> {
  /// The beer tags editor internal constructor.
  const BeerTagsEditorDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<List<String>, BeerTagsEditorDialog> createState() => _BeerTagsEditorDialogState();

  /// Shows a new beer tags editor.
  static Future<FormDialogResult<List<String>>> show({
    required BuildContext context,
    required List<String> tags,
  }) => FormDialog.show(
    context: context,
    object: tags,
    builder: BeerTagsEditorDialog._,
  );
}

/// The beer tags editor dialog state.
class _BeerTagsEditorDialogState extends FormDialogState<List<String>, BeerTagsEditorDialog> {
  /// The current beer tags.
  late List<String>? tags = widget.object;

  /// The add form focus node.
  final FocusNode addFormFocusNode = FocusNode();

  /// The add form controller.
  final TextEditingController addFormController = TextEditingController();

  @override
  List<Widget> createChildren(BuildContext context) => [
    _BeerTagsFormField(
      initialValue: tags,
      addFormFocusNode: addFormFocusNode,
      addFormController: addFormController,
      onSaved: (value) => tags = value,
    ),
  ];

  @override
  List<String>? onSaved() => tags;

  @override
  void dispose() {
    addFormFocusNode.dispose();
    addFormController.dispose();
    super.dispose();
  }
}

/// Allows to edit a beer comments.
class BeerCommentsEditorDialog extends FormDialog<String?> {
  /// The beer comments editor internal constructor.
  const BeerCommentsEditorDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<String?, BeerCommentsEditorDialog> createState() => _BeerCommentsEditorDialogState();

  /// Shows a new beer comments editor.
  static Future<FormDialogResult<String?>> show({
    required BuildContext context,
    required String? comments,
  }) => FormDialog.show(
    context: context,
    object: comments,
    builder: BeerCommentsEditorDialog._,
  );
}

/// The beer comments editor dialog state.
class _BeerCommentsEditorDialogState extends FormDialogState<String?, BeerCommentsEditorDialog> {
  /// The current beer comments.
  late String? comments = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    _BeerCommentsFormField(
      initialText: comments,
      onSaved: (value) => comments = value?.trimOrNullIfEmpty,
    ),
  ];

  @override
  String? onSaved() => comments;
}

/// The beer image form field.
class BeerImageFormField extends FormField<String?> {
  /// Creates a new beer image form field instance.
  BeerImageFormField({
    super.key,
    super.initialValue,
    super.onSaved,
    required String beerUuid,
    String? beerName,
    final ValueChanged<String?>? onChanged,
    bool? enabled,
  }) : super(
         builder: (state) {
           Widget child = BeerImageWidget.fromNameImage(
             name: beerName,
             image: state.value,
             radius: 100,
           );
           return (enabled ?? currentPlatform == Platform.web)
               ? child
               : FPopover(
                   controller: (state as _BeerImageFormState).imagePopoverController,
                   popoverBuilder: (context, controller) => SizedBox(
                     width: math.min(300, MediaQuery.of(context).size.width),
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         FItemGroup(
                           children: [
                             FItem(
                               prefix: const Icon(FIcons.galleryThumbnails),
                               title: Text(translations.beers.dialog.image.gallery),
                               onPress: () async {
                                 String? image = await showWaitingOverlay(
                                   context,
                                   future: _changeImageFromSource(
                                     beerUuid,
                                     ImageSource.gallery,
                                   ),
                                 );
                                 if (image != null) {
                                   state.didChange(image);
                                   onChanged?.call(image);
                                 }
                                 controller.hide();
                               },
                             ),
                             FItem(
                               prefix: const Icon(FIcons.camera),
                               title: Text(translations.beers.dialog.image.camera),
                               onPress: () async {
                                 String? image = await showWaitingOverlay(
                                   context,
                                   future: _changeImageFromSource(
                                     beerUuid,
                                     ImageSource.camera,
                                   ),
                                 );
                                 if (image != null) {
                                   state.didChange(image);
                                   onChanged?.call(image);
                                 }
                                 controller.hide();
                               },
                             ),
                             if (state.value != null)
                               FItem(
                                 prefix: const Icon(FIcons.x),
                                 title: Text(translations.beers.dialog.image.remove),
                                 onPress: () {
                                   state.didChange(null);
                                   onChanged?.call(null);
                                   controller.hide();
                                 },
                               ),
                           ],
                         ),
                       ],
                     ),
                   ),
                   child: GestureDetector(
                     onTap: state.imagePopoverController.show,
                     child: child,
                   ),
                 );
         },
       );

  /// Changes the image of the beer.
  static Future<String?> _changeImageFromSource(
    String beerUuid,
    ImageSource source,
  ) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    return pickedFile == null
        ? null
        : BeerImage.copyImage(
            originalFilePath: pickedFile.path,
            filenamePrefix: beerUuid,
          );
  }

  @override
  FormFieldState<String?> createState() => _BeerImageFormState();
}

/// The beer image form field state.
class _BeerImageFormState extends FormFieldState<String?> with SingleTickerProviderStateMixin {
  /// The current image.
  late String? oldBeerImage = widget.initialValue;

  /// The image popover controller.
  late final FPopoverController imagePopoverController = FPopoverController(vsync: this);

  @override
  void save() {
    super.save();
    if (oldBeerImage != value && oldBeerImage != null) {
      File oldImage = File(oldBeerImage!);
      if (oldImage.existsSync()) {
        oldImage.delete();
      }
    }
  }

  @override
  void dispose() {
    imagePopoverController.dispose();
    super.dispose();
  }
}

/// The beer name form field.
class _BeerNameFormField extends FTextFormField {
  /// Creates a new beer name form field instance.
  _BeerNameFormField({
    super.initialText,
    Function(String)? onChange,
    FormFieldSetter<String>? onSaved,
  }) : super(
         label: Text(translations.beers.dialog.name.label),
         hint: translations.beers.dialog.name.hint,
         validator: emptyStringValidator,
         onChange: (value) => onChange?.call(value.trimOrNullIfEmpty ?? ''),
         onSaved: (value) => onSaved?.call(value?.trimOrNullIfEmpty),
       );
}

/// The beer rating form field.
class _BeerRatingFormField extends FormField<double> {
  /// Creates a new beer rating form field instance.
  _BeerRatingFormField({
    FormFieldSetter<double>? onSaved,
    super.initialValue,
    double size = 50,
  }) : super(
         onSaved: onSaved == null ? null : (value) => onSaved((value ?? 0) <= 0 ? null : value),
         builder: (state) => FLabel(
           label: Text(translations.beers.dialog.rating.label),
           axis: Axis.vertical,
           child: SmoothStarRating(
             rating: state.value ?? 0,
             size: size,
             onRatingChanged: state.didChange,
           ),
         ),
       );

  @override
  FormFieldSetter<double>? get onSaved =>
      (value) => super.onSaved?.call((value ?? 0) <= 0 ? null : value);
}

/// The beer degrees form field.
class _BeerDegreesFormField extends FTextFormField {
  /// Creates a new beer degrees form field instance.
  _BeerDegreesFormField({
    double? initialValue,
    FormFieldSetter<double>? onSaved,
  }) : super(
         label: Text(translations.beers.dialog.degrees.label),
         hint: translations.beers.dialog.degrees.hint,
         initialText: initialValue == null ? null : NumberFormat.formatDouble(initialValue),
         keyboardType: const TextInputType.numberWithOptions(decimal: true),
         validator: numbersValidator,
         onSaved: (value) => onSaved?.call(NumberFormat.tryParseDouble(value)),
       );
}

/// The beer tags form field.
class _BeerTagsFormField extends FormField<List<String>> {
  /// Creates a new beer tags form field instance.
  _BeerTagsFormField({
    super.onSaved,
    super.initialValue,
    TextEditingController? addFormController,
    FocusNode? addFormFocusNode,
  }) : super(
         builder: (FormFieldState<List<String>> state) => Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Padding(
               padding: const EdgeInsets.only(bottom: kSpace / 2),
               child: FTextFormField(
                 focusNode: addFormFocusNode,
                 label: Text(translations.beers.dialog.tags.label),
                 hint: translations.beers.dialog.tags.hint,
                 textInputAction: TextInputAction.send,
                 controller: addFormController,
                 onSubmit: (value) {
                   state.didChange(List.of(state.value ?? [])..add(value));
                   addFormController?.clear();
                   addFormFocusNode?.requestFocus();
                 },
               ),
             ),
             Align(
               alignment: Alignment.centerLeft,
               child: Wrap(
                 spacing: kSpace / 2,
                 runSpacing: kSpace / 2,
                 children: [
                   for (String tag in state.value ?? [])
                     FBadge(
                       child: Row(
                         children: [
                           Text(tag),
                           Padding(
                             padding: const EdgeInsets.only(left: 6),
                             child: GestureDetector(
                               onTap: () => state.didChange(state.value?..remove(tag)),
                               child: const Icon(
                                 FIcons.delete,
                                 size: 20,
                                 color: Colors.white,
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                 ],
               ),
             ),
           ],
         ),
       );
}

/// The beer comments form field.
class _BeerCommentsFormField extends FTextFormField {
  /// Creates a new beer comments form field instance.
  _BeerCommentsFormField({
    super.initialText,
    FormFieldSetter<String>? onSaved,
  }) : super(
         label: Text(translations.beers.dialog.comments.label),
         hint: translations.beers.dialog.comments.hint,
         minLines: 1,
         maxLines: 3,
         onSaved: (value) => onSaved?.call(value?.trimOrNullIfEmpty),
       );
}
