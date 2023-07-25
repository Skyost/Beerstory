import 'dart:io';

import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history/history.dart';
import 'package:beerstory/widgets/editors/beer_editor_dialog.dart';
import 'package:beerstory/widgets/form_fields/rating_form_field.dart';
import 'package:beerstory/widgets/letter_avatar.dart';
import 'package:beerstory/widgets/repository/repository_object.dart';
import 'package:beerstory/widgets/tag.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Allows to show a beer.
class BeerWidget extends RepositoryObjectWidget {
  /// The beer.
  final Beer beer;

  /// Creates a new beer widget instance.
  const BeerWidget({
    super.key,
    required this.beer,
    super.backgroundColor,
    super.padding,
    super.addClickListeners,
  });

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) => Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: BeerImage(beer: beer),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BeerTitle(beer: beer),
                _BeerPrice(beer: beer),
                if (beer.rating != null || beer.tags.isNotEmpty)
                  SizedBox.fromSize(
                    size: const Size.fromHeight(8),
                  ),
                _BeerRating(beer: beer),
                _BeerTags(beer: beer),
              ],
            ),
          ),
        ],
      );

  @override
  void onTap(BuildContext context, WidgetRef ref) => BeerEditorDialog.show(
        context: context,
        beer: beer,
        readOnly: true,
      );

  @override
  void onEdit(BuildContext context, WidgetRef ref) => BeerEditorDialog.show(
        context: context,
        beer: beer,
      );

  @override
  void onDelete(BuildContext context, WidgetRef ref) {
    ref.read(historyProvider).removeBeer(beer);
    ref.read(beerRepositoryProvider).remove(beer);
  }
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
  Widget build(BuildContext context) {
    Widget name = Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Text(
        beer.name,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
      ),
    );

    if (beer.degrees == null) {
      return name;
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: name,
        ),
        TagWidget(text: '${beer.degrees}°'),
      ],
    );
  }
}

/// Allows to display the beer prices.
class _BeerPrice extends StatelessWidget {
  /// The beer.
  final Beer beer;

  /// Creates a new beer prices widget instance.
  const _BeerPrice({
    required this.beer,
  });

  @override
  Widget build(BuildContext context) {
    if (beer.prices.isEmpty) {
      return const SizedBox.shrink();
    }

    NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: EzLocalization.of(context)?.locale.languageCode);
    String text;
    if (beer.prices.length == 1) {
      double? price = beer.prices.first.price;
      if (price == null) {
        return const SizedBox.shrink();
      }

      text = numberFormat.format(price);
    } else {
      double? min = beer.minimumPrice?.price;
      double? max = beer.maximumPrice?.price;
      if (min == null /* || max == null */) {
        return const SizedBox.shrink();
      }

      text = '${numberFormat.format(min)} — ${numberFormat.format(max)}';
    }

    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Text(text),
    );
  }
}

/// Allows to display the beer rating.
class _BeerRating extends StatelessWidget {
  /// The beer.
  final Beer beer;

  /// Creates a new beer rating widget instance.
  const _BeerRating({
    required this.beer,
  });

  @override
  Widget build(BuildContext context) => beer.rating == null
      ? const SizedBox.shrink()
      : RatingFormField(
          initialValue: beer.rating!,
          size: 25,
          readOnly: true,
        );
}

/// Allows to display the beer tags.
class _BeerTags extends StatelessWidget {
  /// The beer.
  final Beer beer;

  /// Creates a new beer tags widget instance.
  const _BeerTags({
    required this.beer,
  });

  @override
  Widget build(BuildContext context) {
    if (beer.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        runSpacing: 4,
        spacing: 4,
        children: [
          for (String tag in beer.tags)
            TagWidget(
              text: tag,
            ),
        ],
      ),
    );
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
    double radius = 50,
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
    this.radius = 50,
  }) : assert(name != null || image != null);

  @override
  Widget build(BuildContext context) => image == null
      ? LetterAvatar(
          text: name!,
          radius: radius,
        )
      : CircleAvatar(
          backgroundColor: Colors.black12,
          backgroundImage: FileImage(File(image!)),
          radius: radius,
        );
}
