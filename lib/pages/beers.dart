import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/pages/body.dart';
import 'package:beerstory/widgets/ordered_list_view.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The beers scaffold body widget.
class BeersScaffoldBody extends ScaffoldBodyWidget<Beer, BeerRepository> {
  /// Creates a new beers scaffold body widget instance.
  BeersScaffoldBody({
    super.key,
  }) : super(
          emptyMessage: translations.beers.page.empty,
        );

  @override
  Widget buildBodyWidget(WidgetRef ref, List<Beer> beers) => OrderedListView<Beer>(
        objects: beers,
        builder: (object) => BeerWidget(
          object: object,
        ),
        reverseOrder: reverseOrder,
      );

  @override
  AsyncNotifierProvider<BeerRepository, List<Beer>> get repositoryProvider => beerRepositoryProvider;
}
