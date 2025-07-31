import 'package:beerstory/model/repository.dart';
import 'package:beerstory/widgets/async_value_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents an app page.
abstract class ScaffoldBodyWidget<T extends RepositoryObject> extends ConsumerWidget {
  /// The prefixes.
  final List<Widget> prefixes;

  /// The suffixes.
  final List<Widget> suffixes;

  /// Whether to order the list in reverse order.
  final bool reverseOrder;

  /// Creates a new page instance.
  const ScaffoldBodyWidget({
    super.key,
    this.prefixes = const [],
    this.suffixes = const [],
    this.reverseOrder = false,
  });

  /// The corresponding repository provider.
  AsyncNotifierProvider<Repository<T>, List<T>> get repositoryProvider;

  /// Builds the body widget (typically, a list view).
  Widget buildBodyWidget(BuildContext context, WidgetRef ref, List<T> object);

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueWidget(
    provider: repositoryProvider,
    builder: buildBodyWidget,
  );
}
