import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/pages/body.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/widgets/empty.dart';
import 'package:beerstory/widgets/ordered_list_view.dart';
import 'package:beerstory/widgets/repository/bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bars scaffold body widget.
class BarsScaffoldBody extends ScaffoldBodyWidget<Bar> {
  /// Creates a new bars scaffold body widget instance.
  const BarsScaffoldBody({
    super.key,
  });

  @override
  Widget buildBodyWidget(BuildContext context, WidgetRef ref, List<Bar> bars) => LayoutBuilder(
    builder: (context, constraints) => OrderedListView<Bar>(
      objects: bars,
      builder: (object) => BarWidget(
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
            text: search == null || search.isEmpty ? translations.bars.page.empty : translations.bars.page.searchEmpty,
          ),
        ),
      ),
    ),
  );

  @override
  AsyncNotifierProvider<BarRepository, List<Bar>> get repositoryProvider => barRepositoryProvider;
}
