import 'dart:io';

import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/utils/platform.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/barcode_scan_button.dart';
import 'package:beerstory/widgets/choice_dialog.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:beerstory/widgets/form_fields/beer_prices_form_field.dart';
import 'package:beerstory/widgets/form_fields/rating_form_field.dart';
import 'package:beerstory/widgets/form_fields/tags_form_field.dart';
import 'package:beerstory/widgets/label.dart';
import 'package:beerstory/widgets/large_button.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// The beer editor.
class BeerEditorDialog extends FormDialog {
  /// The currently edited beer.
  final Beer beer;

  /// Whether this is a preview.
  final bool readOnly;

  /// The beer editor internal constructor.
  const BeerEditorDialog._internal({
    required this.beer,
    this.readOnly = false,
  });

  @override
  FormDialogState<BeerEditorDialog> createState() => _BeerEditorDialogState();

  /// Shows a new beer editor.
  static Future<bool> show({
    required BuildContext context,
    Beer? beer,
    bool readOnly = false,
  }) async =>
      (await showDialog(
        context: context,
        builder: (context) => BeerEditorDialog._internal(
          beer: beer ?? Beer(name: ''),
          readOnly: readOnly,
        ),
      )) ==
      true;
}

/// The beer editor state.
class _BeerEditorDialogState extends FormDialogState<BeerEditorDialog> {
  /// Whether to show more details.
  bool showMore = false;

  /// The current beer name.
  late String beerName;

  @override
  void initState() {
    super.initState();
    beerName = widget.beer.name;
  }

  @override
  List<Widget> createChildren(BuildContext context) => [
        FormField<String>(
          initialValue: widget.beer.image,
          builder: (state) => GestureDetector(
            child: BeerImage.fromNameImage(
              name: beerName,
              image: state.value,
              radius: 100,
            ),
            onTap: () {
              if (!widget.readOnly && currentPlatform.isMobile) {
                showBeerImageChoiceDialog(context, state);
              }
            },
          ),
          onSaved: (value) => widget.beer.image = value,
        ),
        const LabelWidget(
          icon: Icons.edit,
          textKey: 'beerDialog.name.label',
        ),
        _PreviewOrEditWidget(
          preview: widget.readOnly,
          previewText: widget.beer.name,
          editWidget: TextFormField(
            decoration: InputDecoration(hintText: context.getString('beerDialog.name.hint')),
            initialValue: widget.beer.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.getString('error.empty');
              }
              return null;
            },
            onChanged: (value) {
              setState(() => beerName = value);
            },
            onSaved: (value) => widget.beer.name = value ?? '?',
          ),
        ),
        const LabelWidget(
          icon: Icons.local_bar,
          textKey: 'beerDialog.degrees.label',
        ),
        _PreviewOrEditWidget(
          preview: widget.readOnly,
          previewText: widget.beer.degrees == null ? '?' : '${widget.beer.degrees}°',
          editWidget: TextFormField(
            decoration: InputDecoration(hintText: context.getString('beerDialog.degrees.hint')),
            initialValue: (widget.beer.degrees?.toIntIfPossible() ?? '').toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSaved: (value) => widget.beer.degrees = double.tryParse(value ?? '?'),
          ),
        ),
        if (showMore) ...[
          const LabelWidget(
            icon: Icons.star,
            textKey: 'beerDialog.rating.label',
          ),
          RatingFormField(
            readOnly: widget.readOnly,
            initialValue: widget.beer.rating,
            onSaved: (value) => widget.beer.rating = value,
          ),
          const LabelWidget(
            icon: Icons.local_offer,
            textKey: 'beerDialog.tags.label',
          ),
          TagsFormField(
            initialValue: widget.beer.tags,
            addAddForm: !widget.readOnly,
            addFormHint: context.getString('beerDialog.tags.hint'),
            emptyWidget: _LeftAlignedText(text: context.getString('beerDialog.tags.empty')),
            tagDeleteIcon: widget.readOnly ? null : Icons.remove_circle,
            onSaved: (value) => widget.beer.tags = value ?? [],
          ),
          const LabelWidget(
            icon: Icons.attach_money,
            textKey: 'beerDialog.prices.label',
          ),
          BeerPricesFormField(
            initialValue: widget.beer.prices,
            noBarFoundText: context.getString('beerDialog.prices.noBar'),
            emptyWidget: _LeftAlignedText(text: context.getString('beerDialog.prices.empty')),
            onSaved: (value) => widget.beer.prices = value ?? [],
            editablePrices: !widget.readOnly,
          ),
        ] else
          LargeButton(
            padding: const EdgeInsets.only(top: FormDialogState.padding),
            text: context.getString('action.more'),
            onPressed: () {
              setState(() => showMore = true);
            },
          ),
        if (!widget.readOnly && currentPlatform.isMobile)
          Padding(
            padding: EdgeInsets.only(top: showMore ? FormDialogState.padding : 0),
            child: BeerBarcodeScanButton(
              textKey: 'beerDialog.barcode',
              onProductNotFound: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(context.getString('error.openFoodFactsNotFound')),
                backgroundColor: Theme.of(context).colorScheme.error,
              )),
              onError: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(context.getString('error.openFoodFactsGenericError')),
                backgroundColor: Theme.of(context).colorScheme.error,
              )),
              onBeerFound: (beer) {
                BeerRepository beerRepository = ref.read(beerRepositoryProvider);
                beerRepository.add(beer);
                beerRepository.save();
                if (context.mounted) {
                  Navigator.pop(context, false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(context.getString('beerDialog.found', {'element': beer.name})),
                    backgroundColor: Colors.green,
                  ));
                }
              },
            ),
          ),
      ];

  @override
  bool get createCancelButton => !widget.readOnly;

  /// Shows the photo choice dialog.
  void showBeerImageChoiceDialog(BuildContext context, FormFieldState<String> formState) => ChoiceDialog(
        choices: [
          Choice(
            text: 'beerDialog.image.gallery',
            icon: Icons.photo,
            callback: () async {
              XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (file != null) {
                String path = '${(await getApplicationDocumentsDirectory()).path}/${file.path.split('/').last}';
                File(file.path).move(path);
                formState.didChange(path);
              }
            },
          ),
          Choice(
            text: 'beerDialog.image.camera',
            icon: Icons.camera_alt,
            callback: () async {
              XFile? file = await ImagePicker().pickImage(source: ImageSource.camera);
              if (file != null) {
                String path = '${(await getApplicationDocumentsDirectory()).path}/${file.path.split('/').last}';
                File(file.path).move(path);
                formState.didChange(path);
              }
            },
          ),
          if (widget.beer.image != null)
            Choice(
              text: 'beerDialog.image.remove',
              icon: Icons.remove,
              callback: () => widget.beer.image = null,
            ),
        ],
      ).show(context);

  @override
  void onSubmit() {
    if (widget.readOnly) {
      return;
    }
    BeerRepository beerRepository = ref.read(beerRepositoryProvider);
    if (!beerRepository.has(widget.beer)) {
      beerRepository.add(widget.beer);
    }
    beerRepository.save();
  }
}

/// Show a preview text or an edit widget based on the current mode.
class _PreviewOrEditWidget extends StatelessWidget {
  /// Whether to preview or to edit.
  final bool preview;

  /// The preview text.
  final String previewText;

  /// The edit widget.
  final Widget editWidget;

  /// Creates a new preview or edit widget instance.
  const _PreviewOrEditWidget({
    required this.preview,
    required this.previewText,
    required this.editWidget,
  });

  @override
  Widget build(BuildContext context) => preview ? _LeftAlignedText(text: previewText) : editWidget;
}

/// A left aligned text widget.
class _LeftAlignedText extends StatelessWidget {
  /// The text.
  final String text;

  /// Creates a new left aligned text widget instance.
  const _LeftAlignedText({
    required this.text,
  });

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(text),
        ),
      );
}
