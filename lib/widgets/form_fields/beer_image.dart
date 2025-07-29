import 'dart:io';
import 'dart:math' as math;

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

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
  }) : super(
          builder: (state) => FPopover(
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
                            future: _changeImageFromSource(beerUuid, ImageSource.gallery),
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
                            future: _changeImageFromSource(beerUuid, ImageSource.camera),
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
                          prefix: const Icon(FIcons.cross),
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
              child: BeerImage.fromNameImage(
                name: beerName,
                image: state.value,
                radius: 100,
              ),
            ),
          ),
        );

  /// Changes the image of the beer.
  static Future<String?> _changeImageFromSource(String beerUuid, ImageSource source) async {
    try {
      XFile? pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) {
        return null;
      }
      Uri uri = Uri.parse(pickedFile.path);
      String extension = path.extension(uri.pathSegments.last);
      Directory directory = await Beer.getImagesTargetDirectory();
      File file = File(path.join(directory.path, 'manual', '$beerUuid-${DateTime.now().millisecondsSinceEpoch}$extension'));
      file.parent.createSync(recursive: true);
      File(pickedFile.path).copySync(file.path);
      return file.path;
    } catch (ex, stackTrace) {
      printError(ex, stackTrace);
    }
    return null;
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
