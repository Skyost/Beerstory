import 'dart:io';
import 'dart:math' as math;

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/platform.dart';
import 'package:beerstory/utils/scan_beer.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:beerstory/widgets/form_fields/rating_form_field.dart';
import 'package:beerstory/widgets/form_fields/tags_form_field.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

/// The beer editor.
class BeerEditorDialog extends FormDialog<Beer> {
  /// The beer editor internal constructor.
  const BeerEditorDialog._({
    required super.object,
    super.animation,
    super.style,
  });

  @override
  FormDialogState<Beer, BeerEditorDialog> createState() => _BeerEditorDialogState();

  /// Shows a new beer editor.
  static Future<Beer?> show({
    required BuildContext context,
    Beer? beer,
  }) =>
      showFDialog<Beer>(
        context: context,
        builder: (context, style, animation) => BeerEditorDialog._(
          object: beer ?? Beer(),
          style: style.call,
          animation: animation,
        ),
      );
}

/// The beer editor state.
class _BeerEditorDialogState extends FormDialogState<Beer, BeerEditorDialog> with SingleTickerProviderStateMixin<BeerEditorDialog> {
  /// The current beer instance.
  late Beer beer = widget.object.copyWith();

  /// The current image.
  late String? currentImage = beer.image;

  /// The image popover controller.
  late final FPopoverController imagePopoverController = FPopoverController(vsync: this);

  /// Whether to show more details.
  late bool showMore = beer.degrees != null || beer.rating != null || beer.tags.isNotEmpty;

  /// The add form focus node.
  final FocusNode addFormFocusNode = FocusNode();

  /// The add form controller.
  final TextEditingController addFormController = TextEditingController();

  @override
  List<Widget> createChildren(BuildContext context) => [
        FormField<String?>(
          initialValue: beer.image,
          builder: (state) => FPopover(
            controller: imagePopoverController,
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
                            future: changeImageFromSource(ImageSource.gallery),
                          );
                          if (image != null) {
                            state.didChange(image);
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
                            future: changeImageFromSource(ImageSource.camera),
                          );
                          if (image != null) {
                            state.didChange(image);
                          }
                          controller.hide();
                        },
                      ),
                      if (beer.image != null)
                        FItem(
                          prefix: const Icon(FIcons.cross),
                          title: Text(translations.beers.dialog.image.remove),
                          onPress: () {
                            state.didChange(null);
                            controller.hide();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: kSpace * 2),
              child: Center(
                child: GestureDetector(
                  onTap: imagePopoverController.show,
                  child: BeerImage.fromNameImage(
                    name: beer.name,
                    image: state.value,
                    radius: 100,
                  ),
                ),
              ),
            ),
          ),
          onSaved: (value) => beer = beer.overwriteImage(
            image: value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: kSpace),
          child: FTextFormField(
            label: Text(translations.beers.dialog.name.label),
            hint: translations.beers.dialog.name.hint,
            initialText: beer.name,
            validator: (value) {
              if (value?.nullIfEmpty == null) {
                return translations.error.empty;
              }
              return null;
            },
            onSaved: (value) => beer = beer.copyWith(
              name: value?.trim(),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: showMore ? kSpace : kSpace * 2),
          child: FTextFormField(
            label: Text(translations.beers.dialog.degrees.label),
            hint: translations.beers.dialog.degrees.hint,
            initialText: (beer.degrees?.toIntIfPossible() ?? '').toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSaved: (value) => beer = beer.overwriteDegrees(
              degrees: double.tryParse(value ?? ''),
            ),
          ),
        ),
        if (showMore) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: kSpace),
            child: RatingFormField(
              label: Text(translations.beers.dialog.rating.label),
              initialValue: beer.rating,
              onSaved: (value) => beer = beer.overwriteRating(
                rating: (value ?? 0) <= 0 ? null : value,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kSpace),
            child: TagsFormField(
              initialValue: beer.tags,
              label: Text(translations.beers.dialog.tags.label),
              addFormHint: translations.beers.dialog.tags.hint,
              addFormFocusNode: addFormFocusNode,
              addFormController: addFormController,
              tagDeleteIcon: FIcons.delete,
              onSaved: (value) => beer = beer.copyWith(
                tags: value,
              ),
            ),
          ),
          // TODO edit prices button,
        ] else
          Padding(
            padding: EdgeInsets.only(bottom: (currentPlatform.isMobile || kDebugMode) ? kSpace : kSpace * 2),
            child: FButton(
              style: FButtonStyle.secondary(),
              child: Text(translations.misc.more),
              onPress: () {
                setState(() => showMore = true);
              },
            ),
          ),
        if (currentPlatform.isMobile || kDebugMode)
          Padding(
            padding: const EdgeInsets.only(bottom: kSpace * 2),
            child: FButton(
              style: FButtonStyle.secondary(),
              child: Text(translations.beers.dialog.barcode),
              onPress: () async {
                ScanResult result = await scanBeer(context);
                if (context.mounted) {
                  context.handleScanResult(
                    result,
                    onSuccess: (beer) async {
                      bool confirm = await confirmReplaceBeer(context);
                      if (mounted && confirm) {
                        setState(() => this.beer = beer);
                      }
                    },
                  );
                }
              },
            ),
          ),
      ];

  @override
  Beer? onValidated() {
    if (currentImage != beer.image && currentImage != null) {
      File oldImage = File(currentImage!);
      if (oldImage.existsSync()) {
        oldImage.delete();
      }
    }
    return beer;
  }

  @override
  void dispose() {
    addFormFocusNode.dispose();
    addFormController.dispose();
    super.dispose();
  }

  /// Changes the image of the beer.
  Future<String?> changeImageFromSource(ImageSource source) async {
    try {
      XFile? pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) {
        return null;
      }
      Uri uri = Uri.parse(pickedFile.path);
      String extension = path.extension(uri.pathSegments.last);
      Directory directory = await Beer.getImagesTargetDirectory();
      File file = File(path.join(directory.path, 'manual', '${beer.uuid}-${DateTime.now().millisecondsSinceEpoch}$extension'));
      file.parent.createSync(recursive: true);
      File(pickedFile.path).copySync(file.path);
      return file.path;
    } catch (ex, stackTrace) {
      printError(ex, stackTrace);
    }
    return null;
  }

  /// Shows a confirmation dialog to replace the current beer.
  Future<bool> confirmReplaceBeer(BuildContext context) async => (await showFDialog<bool>(
        context: context,
        builder: (context, style, animation) => FDialog.adaptive(
          style: style.call,
          animation: animation,
          body: Text(translations.beers.dialog.replace),
          actions: [
            FButton(
              style: FButtonStyle.outline(),
              onPress: () => Navigator.pop(context, false),
              child: Text(translations.misc.no),
            ),
            FButton(
              onPress: () => Navigator.pop(context, true),
              child: Text(translations.misc.yes),
            ),
          ],
        ),
      ) ==
      true);
}
