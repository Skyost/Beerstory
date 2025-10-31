import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/widgets/circular_progress_indicator.dart';
import 'package:beerstory/widgets/empty.dart';
import 'package:beerstory/widgets/error.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Builds a list of widgets from an [AsyncValue].
List<Widget> buildAsyncValueWidgetList<T>({
  VoidCallback? onRetryPressed,
  required AsyncValue<T> asyncValue,
  required List<Widget> Function(T) builder,
  String? nullText,
}) {
  if (asyncValue.isLoading) {
    return [
      const CenteredProgressIndicator(),
    ];
  }
  if (asyncValue.hasError) {
    return [
      ErrorWidget(
        error: asyncValue.error!,
        stackTrace: asyncValue.stackTrace,
        onRetryPressed: onRetryPressed,
      ),
    ];
  }
  if (asyncValue.value == null) {
    return [
      Center(
        child: EmptyWidget(
          text: nullText ?? translations.misc.notFound,
        ),
      ),
    ];
  }
  return builder(asyncValue.value!);
}

/// Allows to easily build a [Widget] from an [AsyncValue].
class AsyncValueWidget<T> extends ConsumerWidget {
  /// The corresponding provider.
  final ProviderListenable<AsyncValue<T>> provider;

  /// Builds the children once the data is loaded.
  final Widget Function(BuildContext, WidgetRef, T) builder;

  /// The text shown when the data is null.
  final String? nullText;

  /// Creates a new async value widget instance.
  const AsyncValueWidget({
    super.key,
    required this.provider,
    required this.builder,
    this.nullText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<T> asyncValue = ref.watch(provider);
    return buildAsyncValueWidgetList(
      asyncValue: asyncValue,
      builder: (value) => [builder(context, ref, value)],
      onRetryPressed: provider is Refreshable ? () => ref.refresh(provider as Refreshable) : null,
      nullText: nullText,
    ).first;
  }
}
