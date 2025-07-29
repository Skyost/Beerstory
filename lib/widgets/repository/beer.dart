import 'dart:io';

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/price/price.dart';
import 'package:beerstory/model/beer/price/repository.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/adaptive.dart';
import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:beerstory/widgets/editors/beer_edit.dart';
import 'package:beerstory/widgets/form_fields/beer_image.dart';
import 'package:beerstory/widgets/form_fields/rating.dart';
import 'package:beerstory/widgets/repository/beer_prices.dart';
import 'package:beerstory/widgets/repository/repository_object.dart';
import 'package:beerstory/widgets/scrollable_sheet_content.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

/// Allows to show a beer.
class BeerWidget extends RepositoryObjectWidget<Beer> {
  /// Creates a new beer widget instance.
  const BeerWidget({
    super.key,
    required super.object,
  });

  @override
  Widget buildTitle(BuildContext context) => _BeerTitle(beer: object);

  @override
  Widget buildPrefix(BuildContext context) => BeerImage(
    beer: object,
    radius: context.theme.style.iconStyle.size,
  );

  @override
  Widget? buildSuffix(BuildContext context) => BeerDegrees(
    beer: object,
    inBadge: true,
  );

  @override
  Widget? buildSubtitle(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 2,
    children: [
      _BeerPrices(
        beer: object,
        showEmptyMessage: false,
      ),
      _BeerRating(
        beer: object,
        showEmptyMessage: false,
        size: 20,
      ),
      _BeerTags(
        beer: object,
        showEmptyMessage: false,
      ),
    ],
  );

  @override
  Widget buildDetailsWidget(BuildContext context, ScrollController scrollController) => _BeerDetailsWidget(
    beerUuid: object.uuid,
    scrollController: scrollController,
    onBeerPricesPress: () {
      showFSheet(
        context: context,
        builder: (context) => ScrollableSheetContentWidget(
          builder: (context, scrollController) => PricesDetailsWidget.create<Beer>(
            scrollController: scrollController,
            objectUuid: object.uuid,
          ),
        ),
        side: FLayout.btt,
        mainAxisMaxRatio: null,
      );
    },
  );
}

/// Allows to show a beer details.
class _BeerDetailsWidget extends ConsumerWidget {
  /// The beer UUID.
  final String beerUuid;

  /// The scroll controller.
  final ScrollController? scrollController;

  /// The beer prices press callback.
  final VoidCallback? onBeerPricesPress;

  /// Creates a new beer details widget instance.
  const _BeerDetailsWidget({
    required this.beerUuid,
    this.scrollController,
    this.onBeerPricesPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Beer? beer = ref.watch(beerRepositoryProvider.select((bars) => bars.value?.findByUuid(beerUuid)));
    if (beer == null) {
      return const CenteredCircularProgressIndicator();
    }
    List<FButton> actions = [
      FButton(
        style: FButtonStyle.destructive(),
        child: Text(translations.misc.delete),
        onPress: () async {
          if (await showDeleteConfirmationDialog(context)) {
            ref.read(beerRepositoryProvider.notifier).remove(beer);
          }
        },
      ),
    ];
    return ListView(
      controller: scrollController,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: kSpace),
          child: Center(
            child: BeerImageFormField(
              initialValue: beer.image,
              beerUuid: beer.uuid,
              beerName: beer.name,
              onChanged: (newImage) async {
                if (context.mounted && newImage != beer.image) {
                  await editBeer(context, ref, beer.overwriteImage(image: newImage));
                }
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: kSpace * 2),
          child: FTileGroup(
            label: Text(translations.beers.details.title),
            children: [
              FTile(
                prefix: const Icon(FIcons.pencil),
                title: Text(translations.beers.details.name.label),
                subtitle: _BeerTitle(beer: beer),
                suffix: const Icon(FIcons.chevronRight),
                onPress: () async {
                  String? newName = await BeerNameEditorDialog.show(
                    context: context,
                    beerName: beer.name,
                  );
                  if (newName != null && newName != beer.name && context.mounted) {
                    await editBeer(context, ref, beer.copyWith(name: newName));
                  }
                },
              ),
              FTile(
                prefix: const Icon(FIcons.thermometer),
                title: Text(translations.beers.details.degrees.label),
                subtitle: BeerDegrees(beer: beer),
                suffix: const Icon(FIcons.chevronRight),
                onPress: () async {
                  double? newDegrees = await BeerDegreesEditorDialog.show(
                    context: context,
                    beerDegrees: beer.degrees,
                  );
                  if (newDegrees != null && newDegrees != beer.degrees && context.mounted) {
                    await editBeer(context, ref, beer.overwriteDegrees(degrees: newDegrees));
                  }
                },
              ),
              FTile(
                prefix: const Icon(FIcons.star),
                title: Text(translations.beers.details.rating.label),
                subtitle: _BeerRating(beer: beer),
                suffix: const Icon(FIcons.chevronRight),
                onPress: () async {
                  double? newRating = await BeerRatingEditorDialog.show(
                    context: context,
                    beerRating: beer.rating,
                  );
                  if (newRating != null && newRating != beer.rating && context.mounted) {
                    await editBeer(context, ref, beer.overwriteRating(rating: newRating));
                  }
                },
              ),
              FTile(
                prefix: const Icon(FIcons.tag),
                title: Text(translations.beers.details.tags.label),
                subtitle: _BeerTags(beer: beer),
                suffix: const Icon(FIcons.chevronRight),
                onPress: () async {
                  List<String>? newTags = await BeerTagsEditorDialog.show(
                    context: context,
                    beerTags: beer.tags,
                  );
                  if (newTags != null && !listEquals(newTags, beer.tags) && context.mounted) {
                    await editBeer(context, ref, beer.copyWith(tags: newTags));
                  }
                },
              ),
              FTile(
                prefix: const Icon(FIcons.beer),
                title: Text(translations.beers.details.prices.label),
                subtitle: _BeerPrices(beer: beer),
                suffix: const Icon(FIcons.chevronRight),
                onPress: onBeerPricesPress,
              ),
            ],
          ),
        ),
        actions.adaptiveWrapper,
      ],
    );
  }

  /// Edits a given beer and shows a waiting overlay.
  Future<void> editBeer(BuildContext context, WidgetRef ref, Beer editedBeer) async {
    await showWaitingOverlay(
      context,
      future: ref.read(beerRepositoryProvider.notifier).change(editedBeer),
    );
  }

  /// Shows a delete confirmation dialog.
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async =>
      (await showFDialog(
        context: context,
        builder: (context, style, animation) => FDialog.adaptive(
          body: Text(translations.beers.deleteConfirm),
          actions: [
            FButton(
              style: FButtonStyle.outline(),
              child: Text(translations.misc.cancel),
              onPress: () => Navigator.pop(context, false),
            ),
            FButton(
              style: FButtonStyle.destructive(),
              child: Text(translations.misc.yes),
              onPress: () => Navigator.pop(context, true),
            ),
          ],
        ),
      )) ==
      true;
}

/// Allows to display the beer title.
class _BeerTitle extends StatelessWidget {
  /// The beer.
  final Beer beer;

  /// Creates a new beer title widget instance.
  const _BeerTitle({
    required this.beer,
  });

  @override
  Widget build(BuildContext context) => Text(
    beer.name,
    overflow: TextOverflow.ellipsis,
  );
}

/// Allows to display the beer prices.
class _BeerPrices extends ConsumerWidget {
  /// The beer.
  final Beer beer;

  /// Whether to show a message if empty.
  final bool showEmptyMessage;

  /// Creates a new beer prices widget instance.
  const _BeerPrices({
    required this.beer,
    this.showEmptyMessage = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<BeerPrice>> prices = ref.watch(beerPricesFromBeerProvider(beer));
    if (!prices.hasValue || prices.value!.isEmpty) {
      return showEmptyMessage ? Text(translations.beers.details.prices.empty) : const SizedBox.shrink();
    }

    NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: TranslationProvider.of(context).locale.languageCode);
    String text;
    if (prices.value!.length == 1) {
      double amount = prices.value!.first.amount;
      text = numberFormat.format(amount);
    } else {
      double min = prices.value!.minimumPrice!.amount;
      double max = prices.value!.maximumPrice!.amount;
      text = min == max ? numberFormat.format(min) : '${numberFormat.format(min)} — ${numberFormat.format(max)}';
    }

    return Text(text);
  }
}

/// Allows to display the beer rating.
class _BeerRating extends StatelessWidget {
  /// The beer.
  final Beer beer;

  /// Whether to show a message if empty.
  final bool showEmptyMessage;

  /// The stars size.
  final double size;

  /// Creates a new beer rating widget instance.
  const _BeerRating({
    required this.beer,
    this.showEmptyMessage = true,
    this.size = 25,
  });

  @override
  Widget build(BuildContext context) {
    if (beer.rating == null) {
      return showEmptyMessage ? Text(translations.beers.details.rating.empty) : const SizedBox.shrink();
    }
    return RatingFormField(
      initialValue: beer.rating,
      size: size,
      readOnly: true,
    );
  }
}

/// Allows to display the beer tags.
class _BeerTags extends StatelessWidget {
  /// The beer.
  final Beer beer;

  /// Whether to show a message if empty.
  final bool showEmptyMessage;

  /// Creates a new beer tags widget instance.
  const _BeerTags({
    required this.beer,
    this.showEmptyMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    if (beer.tags.isEmpty) {
      return showEmptyMessage ? Text(translations.beers.details.tags.empty) : const SizedBox.shrink();
    }

    return Wrap(
      runSpacing: kSpace / 2,
      spacing: kSpace / 2,
      children: [
        for (String tag in beer.tags)
          FBadge(
            child: Text(tag),
          ),
      ],
    );
  }
}

/// Allows to display the beer degrees.
class BeerDegrees extends StatelessWidget {
  /// The beer.
  final Beer beer;

  /// Whether to display the degrees in a badge.
  final bool inBadge;

  /// Creates a new beer degrees widget instance.
  const BeerDegrees({
    super.key,
    required this.beer,
    this.inBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (inBadge) {
      return beer.degrees == null ? const SizedBox.shrink() : FBadge(child: Text('${beer.degrees}°'));
    }
    return beer.degrees == null ? Text(translations.beers.details.degrees.empty) : Text('${beer.degrees}°');
  }
}

/// Allows to display a beer image.
class BeerImage extends StatelessWidget {
  /// The name.
  final String? name;

  /// The image.
  final String? image;

  /// The radius.
  final double radius;

  /// Creates a beer image from a beer.
  BeerImage({
    Key? key,
    Beer? beer,
    double? radius,
  }) : this.fromNameImage(
         key: key,
         name: beer?.name,
         image: beer?.image,
         radius: radius,
       );

  /// Creates a beer image from a name and an image.
  const BeerImage.fromNameImage({
    super.key,
    this.name,
    this.image,
    double? radius,
  }) : radius = radius ?? 50,
       assert(name != null || image != null);

  @override
  Widget build(BuildContext context) => FAvatar(
    image: image == null ? const NetworkImage('') as ImageProvider : FileImage(File(image!)),
    fallback: Text(_textToWrite),
    size: radius * 2,
  );

  /// Returns the text to write.
  String get _textToWrite {
    if (name == null) {
      return '?';
    }

    String text = name!.replaceAll(RegExp(r'[^\s\w]'), '').trim().toUpperCase();
    if (text.isEmpty) {
      return '?';
    }

    List<String> parts = text.split(' ');
    if (parts.length == 1) {
      List<String> otherSplit = text.split('-');
      if (otherSplit.length > 1 && otherSplit[1].isNotEmpty) {
        return otherSplit[0][0] + otherSplit[1][0];
      }

      if (text.length == 2) {
        return text;
      }

      return parts[0][0];
    }

    return parts[0][0] + parts[1][0];
  }
}
