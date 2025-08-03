import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/pages/body.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The beers scaffold body widget.
class BeersScaffoldBody extends ScaffoldBodyWidget<Beer> with AlphabeticalGroup<Beer> {
  /// Creates a new beers scaffold body widget instance.
  const BeersScaffoldBody({
    super.key,
  });

  @override
  AsyncNotifierProvider<BeerRepository, List<Beer>> get repositoryProvider => beerRepositoryProvider;

  @override
  BeerWidget buildObjectWidget(Beer object) => BeerWidget(object: object);

  @override
  String getEmptyWidgetText(String? search) => search == null || search.isEmpty ? translations.beers.page.empty : translations.beers.page.searchEmpty;
}
