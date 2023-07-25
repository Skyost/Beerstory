import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/pages/page.dart';
import 'package:beerstory/widgets/editors/beer_editor_dialog.dart';
import 'package:beerstory/widgets/history_button.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The beers page.
class BeersPage extends Page<Beer> {
  /// Creates a new beers page instance.
  const BeersPage({
    super.key,
  }) : super(
          icon: Icons.list,
          titleKey: 'page.beers.name',
          emptyMessageKey: 'page.beers.empty',
          actions: const [
            _AddBeerButton(),
            HistoryButton(),
          ],
        );

  @override
  Widget createObjectWidget(Beer object, int position) => BeerWidget(
        beer: object,
        backgroundColor: position % 2 == 0 ? Colors.black.withOpacity(0.03) : null,
      );

  @override
  BeerRepository watchRepository(WidgetRef ref) => ref.watch(beerRepositoryProvider);
}

/// The add beer button.
class _AddBeerButton extends StatelessWidget {
  /// Creates a new add beer button instance.
  const _AddBeerButton();

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => BeerEditorDialog.show(context: context),
      );
}
