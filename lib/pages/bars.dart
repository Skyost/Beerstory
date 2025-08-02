import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/pages/body.dart';
import 'package:beerstory/widgets/repository/bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bars scaffold body widget.
class BarsScaffoldBody extends ScaffoldBodyWidget<Bar> with AlphabeticalGroup<Bar> {
  /// Creates a new bars scaffold body widget instance.
  const BarsScaffoldBody({
    super.key,
  });

  @override
  AsyncNotifierProvider<BarRepository, List<Bar>> get repositoryProvider => barRepositoryProvider;

  @override
  BarWidget buildObjectWidget(Bar object) => BarWidget(object: object);

  @override
  String getEmptyWidgetText(String? search) => search == null || search.isEmpty ? translations.bars.page.empty : translations.bars.page.searchEmpty;
}
