import 'dart:io';

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/price/price.dart';
import 'package:beerstory/model/beer/price/repository.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/blank_image_provider.dart';
import 'package:beerstory/utils/format.dart';
import 'package:beerstory/widgets/editors/beer_edit.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:beerstory/widgets/repository/beer_prices.dart';
import 'package:beerstory/widgets/repository/repository_object.dart';
import 'package:beerstory/widgets/scrollable_sheet_content.dart';
import 'package:beerstory/widgets/smooth_star_rating.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

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
  Widget buildPrefix(BuildContext context) => BeerImageWidget(
    beer: object,
    radius: context.theme.style.iconStyle.size,
  );

  @override
  Widget? buildSuffix(BuildContext context) => _BeerDegrees(
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
    objectUuid: object.uuid,
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
        useSafeArea: true,
      );
    },
  );
}

/// Allows to show a beer details.
class _BeerDetailsWidget extends RepositoryObjectDetailsWidget<Beer> {
  /// The beer prices press callback.
  final VoidCallback? onBeerPricesPress;

  /// Creates a new beer details widget instance.
  const _BeerDetailsWidget({
    required super.objectUuid,
    super.scrollController,
    this.onBeerPricesPress,
  });

  @override
  String get deleteConfirmationMessage => translations.beers.deleteConfirm;

  @override
  AsyncNotifierProvider<Repository<Beer>, List<Beer>> get repositoryProvider => beerRepositoryProvider;

  @override
  List<Widget> buildChildren(BuildContext context, WidgetRef ref, Beer object) => [
    Center(
      child: BeerImageFormField(
        initialValue: object.image,
        beerUuid: object.uuid,
        beerName: object.name,
        onChanged: (newImage) async {
          if (context.mounted && newImage != object.image) {
            await editObject(
              context,
              ref,
              object.overwriteImage(image: newImage),
            );
          }
        },
      ),
    ),
    FTileGroup(
      label: Text(translations.beers.details.title),
      children: [
        FTile(
          prefix: const Icon(FIcons.pencil),
          title: Text(translations.beers.details.name.label),
          subtitle: _BeerTitle(beer: object),
          suffix: const Icon(FIcons.chevronRight),
          onPress: () async {
            FormDialogResult<String> newName = await BeerNameEditorDialog.show(
              context: context,
              name: object.name,
            );
            if (newName is FormDialogResultSaved<String> && newName.value != object.name && context.mounted) {
              await editObject(context, ref, object.copyWith(name: newName.value));
            }
          },
        ),
        FTile(
          prefix: const Icon(FIcons.thermometer),
          title: Text(translations.beers.details.degrees.label),
          subtitle: _BeerDegrees(beer: object),
          suffix: const Icon(FIcons.chevronRight),
          onPress: () async {
            FormDialogResult<double?> newDegrees = await BeerDegreesEditorDialog.show(
              context: context,
              degrees: object.degrees,
            );
            if (newDegrees is FormDialogResultSaved<double?> && newDegrees.value != object.degrees && context.mounted) {
              await editObject(
                context,
                ref,
                object.overwriteDegrees(degrees: newDegrees.value),
              );
            }
          },
        ),
        FTile(
          prefix: const Icon(FIcons.star),
          title: Text(translations.beers.details.rating.label),
          subtitle: _BeerRating(beer: object),
          suffix: const Icon(FIcons.chevronRight),
          onPress: () async {
            FormDialogResult<double?> newRating = await BeerRatingEditorDialog.show(
              context: context,
              rating: object.rating,
            );
            if (newRating is FormDialogResultSaved<double?> && newRating.value != object.rating && context.mounted) {
              await editObject(
                context,
                ref,
                object.overwriteRating(rating: newRating.value),
              );
            }
          },
        ),
        FTile(
          prefix: const Icon(FIcons.tag),
          title: Text(translations.beers.details.tags.label),
          subtitle: _BeerTags(beer: object),
          suffix: const Icon(FIcons.chevronRight),
          onPress: () async {
            FormDialogResult<List<String>> newTags = await BeerTagsEditorDialog.show(
              context: context,
              tags: object.tags,
            );
            if (newTags is FormDialogResultSaved<List<String>> && !listEquals(newTags.value, object.tags) && context.mounted) {
              await editObject(context, ref, object.copyWith(tags: newTags.value));
            }
          },
        ),
        FTile(
          prefix: const Icon(FIcons.beer),
          title: Text(translations.beers.details.prices.label),
          subtitle: _BeerPrices(beer: object),
          suffix: const Icon(FIcons.chevronRight),
          onPress: onBeerPricesPress,
        ),
        FTile(
          prefix: const Icon(FIcons.messageSquare),
          title: Text(translations.beers.details.comment.label),
          subtitle: (object.comment?.isEmpty ?? true) ? Text(translations.bars.details.comment.empty) : Text(object.comment!),
          suffix: const Icon(FIcons.chevronRight),
          onPress: () async {
            FormDialogResult<String?> newComment = await BeerCommentEditorDialog.show(
              context: context,
              comment: object.comment,
            );
            if (newComment is FormDialogResultSaved<String?> && newComment.value != object.comment && context.mounted) {
              await editObject(
                context,
                ref,
                object.overwriteComment(comment: newComment.value),
              );
            }
          },
        ),
        if (kDebugMode)
          FTile(
            prefix: const Icon(FIcons.hash),
            title: const Text('UUID'),
            subtitle: Text(object.uuid),
          ),
      ],
    ),
  ];
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
    AsyncValue<List<BeerPrice>> prices = ref.watch(
      beerPricesFromBeerProvider(beer.uuid),
    );
    if (!prices.hasValue || prices.value!.isEmpty) {
      return showEmptyMessage ? Text(translations.beers.details.prices.empty) : const SizedBox.shrink();
    }

    String text;
    if (prices.value!.length == 1) {
      double amount = prices.value!.first.amount;
      text = NumberFormat.formatPrice(amount);
    } else {
      double min = prices.value!.minimumPrice!.amount;
      double max = prices.value!.maximumPrice!.amount;
      text = min == max ? NumberFormat.formatPrice(min) : '${NumberFormat.formatPrice(min)} — ${NumberFormat.formatPrice(max)}';
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
    return SmoothStarRating(
      rating: beer.rating ?? 0,
      size: size,
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
class _BeerDegrees extends StatelessWidget {
  /// The beer.
  final Beer beer;

  /// Whether to display the degrees in a badge.
  final bool inBadge;

  /// Creates a new beer degrees widget instance.
  const _BeerDegrees({
    required this.beer,
    this.inBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (inBadge) {
      return beer.degrees == null ? const SizedBox.shrink() : FBadge(child: Text('${NumberFormat.formatDouble(beer.degrees!)}°'));
    }
    return beer.degrees == null ? Text(translations.beers.details.degrees.empty) : Text('${NumberFormat.formatDouble(beer.degrees!)}°');
  }
}

/// Allows to display a beer image.
class BeerImageWidget extends StatelessWidget {
  /// The name.
  final String? name;

  /// The image.
  final String? image;

  /// The radius.
  final double radius;

  /// Creates a beer image from a beer.
  BeerImageWidget({
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
  const BeerImageWidget.fromNameImage({
    super.key,
    this.name,
    this.image,
    double? radius,
  }) : radius = radius ?? 50,
       assert(name != null || image != null);

  @override
  Widget build(BuildContext context) => FAvatar(
    image: image == null ? const BlankImageProvider() as ImageProvider : FileImage(File(image!)),
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
