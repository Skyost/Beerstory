import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/pages/body.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/widgets/empty.dart';
import 'package:beerstory/widgets/ordered_list_view.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The beers scaffold body widget.
class BeersScaffoldBody extends ScaffoldBodyWidget<Beer> {
  /// Creates a new beers scaffold body widget instance.
  const BeersScaffoldBody({
    super.key,
  });

  @override
  Widget buildBodyWidget(
    BuildContext context,
    WidgetRef ref,
    List<Beer> beers,
  ) => LayoutBuilder(
    builder: (context, constraints) => OrderedListView<Beer>(
      objects: beers,
      builder: (object) => BeerWidget(
        object: object,
      ),
      reverseOrder: reverseOrder,
      emptyWidgetBuilder: (context, search) => Container(
        padding: const EdgeInsets.all(kSpace),
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: Center(
          child: EmptyWidget(
            text: search == null || search.isEmpty ? translations.beers.page.empty : translations.beers.page.searchEmpty,
          ),
        ),
      ),
    ),
  );

  @override
  AsyncNotifierProvider<BeerRepository, List<Beer>> get repositoryProvider => beerRepositoryProvider;
}
