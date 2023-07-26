import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/widgets/editors/bar_editor_dialog.dart';
import 'package:beerstory/widgets/repository/repository_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Allows to show a bar.
class BarWidget extends RepositoryObjectWidget {
  /// The bar.
  final Bar bar;

  /// Creates a new bar widget instance.
  const BarWidget({
    super.key,
    required this.bar,
    super.backgroundColor,
  });

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    Widget name = Text(
      bar.name,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
    );

    if (bar.address == null || bar.address!.isEmpty) {
      return name;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        name,
        Text(
          bar.address!,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  void onTap(BuildContext context, WidgetRef ref) => bar.address == null ? onLongPress(context, ref) : _showBarOnMap(context);

  @override
  void onEdit(BuildContext context, WidgetRef ref) => BarEditorDialog.show(
        context: context,
        bar: bar,
      );

  @override
  void onDelete(BuildContext context, WidgetRef ref) {
    ref.read(beerRepositoryProvider).removeBar(bar);
    ref.read(barRepositoryProvider).remove(bar);
  }

  /// Opens Google Maps to show the bar address.
  void _showBarOnMap(BuildContext context) {
    String query = bar.name;
    if (bar.address != null && bar.address!.isNotEmpty) {
      query += ', ${bar.address}';
    }
    launchUrlString('https://www.google.com/maps/search/?api=1&query=${Uri.encodeQueryComponent(query)}');
  }
}
