import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/pages/body.dart';
import 'package:beerstory/widgets/ordered_list_view.dart';
import 'package:beerstory/widgets/repository/bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bars scaffold body widget.
class BarsScaffoldBody extends ScaffoldBodyWidget<Bar, BarRepository> {
  /// Creates a new bars scaffold body widget instance.
  BarsScaffoldBody({
    super.key,
  }) : super(
          emptyMessage: translations.bars.page.empty,
        );

  @override
  Widget buildBodyWidget(WidgetRef ref, List<Bar> bars) => OrderedListView<Bar>(
        objects: bars,
        builder: (object) => BarWidget(
          object: object,
        ),
        reverseOrder: reverseOrder,
      );

  @override
  AsyncNotifierProvider<BarRepository, List<Bar>> get repositoryProvider => barRepositoryProvider;
}
