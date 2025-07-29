import 'package:beerstory/model/repository.dart';
import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:beerstory/widgets/empty.dart';
import 'package:beerstory/widgets/error.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents an app page.
abstract class ScaffoldBodyWidget<T extends RepositoryObject, R extends Repository<T>> extends ConsumerWidget {
  /// The empty message.
  final String emptyMessage;

  /// The prefixes.
  final List<Widget> prefixes;

  /// The suffixes.
  final List<Widget> suffixes;

  /// Whether to order the list in reverse order.
  final bool reverseOrder;

  /// Creates a new page instance.
  const ScaffoldBodyWidget({
    super.key,
    required this.emptyMessage,
    this.prefixes = const [],
    this.suffixes = const [],
    this.reverseOrder = false,
  });

  /// The corresponding repository provider.
  AsyncNotifierProvider<R, List<T>> get repositoryProvider;

  /// Builds the body widget (typically, a list view).
  Widget buildBodyWidget(WidgetRef ref, List<T> object);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<T>> objects = ref.watch(repositoryProvider);
    if (objects.isLoading) {
      return const CenteredCircularProgressIndicator();
    }

    if (objects.hasError) {
      return ErrorWidget(
        error: objects.error!,
        stackTrace: objects.stackTrace,
        onRetryPressed: () => ref.refresh(repositoryProvider),
      );
    }

    if (objects.value!.isEmpty) {
      return Center(
        child: EmptyWidget(text: emptyMessage),
      );
    }

    return buildBodyWidget(ref, objects.value!);
  }
}
