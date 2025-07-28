import 'package:beerstory/model/repository.dart';
import 'package:beerstory/pages/history.dart';
import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:beerstory/widgets/empty.dart';
import 'package:beerstory/widgets/error.dart';
import 'package:beerstory/widgets/ordered_list_view.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Represents an app page.
abstract class PageWidget<T extends RepositoryObject, R extends Repository<T>> extends ConsumerWidget {
  /// The page icon.
  final IconData icon;

  /// The page title.
  final String title;

  /// The empty message.
  final String emptyMessage;

  /// The prefixes.
  final List<Widget> prefixes;

  /// The suffixes.
  final List<Widget> suffixes;

  /// Whether to order the list in reverse order.
  final bool reverseOrder;

  /// Creates a new page instance.
  const PageWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.emptyMessage,
    this.prefixes = const [],
    this.suffixes = const [],
    this.reverseOrder = false,
  });

  /// The corresponding repository provider.
  AsyncNotifierProvider<R, List<T>> get repositoryProvider;

  /// Allows to create an object widget.
  Widget createObjectWidget(T object, int position);

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

    return OrderedListView<T>(
      items: objects.value!,
      itemBuilder: (objects, position) => createObjectWidget(objects[position], position),
      reverseOrder: reverseOrder,
    );
  }
}

/// A simple history button.
class HistoryButton extends StatelessWidget {
  /// Creates a new history button instance.
  const HistoryButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) => FHeaderAction(
        icon: const Icon(FIcons.history),
        onPress: () => Navigator.pushNamed(context, HistoryPage.page),
      );
}
