import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/adaptive.dart';
import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:beerstory/widgets/editors/bar_editor_dialog.dart';
import 'package:beerstory/widgets/repository/repository_object.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Allows to show a bar.
class BarWidget extends RepositoryObjectWidget<Bar> {
  /// Creates a new bar widget instance.
  const BarWidget({
    super.key,
    required super.object,
  });

  @override
  Widget? buildPrefix(BuildContext context) => Icon(FIcons.mapPin);

  @override
  Widget buildTitle(BuildContext context) => Text(object.name);

  @override
  Widget? buildSubtitle(BuildContext context) => (object.address?.isEmpty ?? true) ? Text(translations.bars.details.address.empty) : Text(object.address!);

  @override
  Widget buildDetailsWidget(BuildContext context, ScrollController scrollController) => _BarDetailsWidget(
        barUuid: object.uuid,
        scrollController: scrollController,
      );
}

/// Allows to show a bar details.
class _BarDetailsWidget extends ConsumerWidget {
  /// The bar UUID.
  final String barUuid;

  /// The scroll controller.
  final ScrollController? scrollController;

  /// Creates a new bar details widget instance.
  const _BarDetailsWidget({
    required this.barUuid,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Bar? bar = ref.watch(barRepositoryProvider.select((bars) => bars.value?.findByUuid(barUuid)));
    if (bar == null) {
      return CenteredCircularProgressIndicator();
    }
    List<FButton> actions = [
      FButton(
        onPress: () => showBarOnMap(bar),
        child: Text(translations.bars.details.showOnMap),
      ),
      FButton(
        // style: FButtonStyle.secondary(),
        onPress: () async {
          Bar? editedBar = await BarEditorDialog.show(
            context: context,
            bar: bar,
          );
          if (editedBar != null && context.mounted) {
            await showWaitingOverlay(
              context,
              future: ref.read(barRepositoryProvider.notifier).change(editedBar),
            );
          }
        },
        child: Text(translations.misc.edit),
      ),
      FButton(
        style: FButtonStyle.destructive(),
        child: Text(translations.misc.delete),
        onPress: () async {
          if (await showDeleteConfirmationDialog(context)) {
            ref.read(barRepositoryProvider.notifier).remove(bar);
          }
        },
      )
    ];
    return ListView(
      controller: scrollController,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: kSpace),
          child: FTileGroup(
            label: Text(translations.bars.details.title),
            children: [
              FTile(
                prefix: Icon(FIcons.pencil),
                title: Text(translations.bars.details.name.label),
                subtitle: _BarName(bar: bar),
              ),
              FTile(
                prefix: Icon(FIcons.mapPin),
                title: Text(translations.bars.details.address.label),
                subtitle: _BarAddress(bar: bar),
              ),
            ],
          ),
        ),
        actions.adaptiveWrapper,
      ],
    );
  }

  /// Shows a delete confirmation dialog.
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async =>
      (await showFDialog(
        context: context,
        builder: (context, style, animation) => FDialog.adaptive(
          body: Text(translations.bars.deleteConfirm),
          actions: [
            FButton(
              style: FButtonStyle.outline(),
              child: Text(translations.misc.cancel),
              onPress: () => Navigator.pop(context, false),
            ),
            FButton(
              style: FButtonStyle.destructive(),
              child: Text(translations.misc.yes),
              onPress: () => Navigator.pop(context, true),
            ),
          ],
        ),
      )) ==
      true;

  /// Opens Google Maps to show the bar address.
  void showBarOnMap(Bar bar) {
    String query = bar.name;
    if (bar.address != null && bar.address!.isNotEmpty) {
      query += ', ${bar.address}';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      launchUrl(
        Uri.https(
          'maps.apple.com',
          '',
          {'q': query},
        ),
      );
    } else {
      launchUrl(
        Uri.https(
          'google.com',
          'maps/search/',
          {'api': '1', 'query': query},
        ),
      );
    }
  }
}

/// Allows to display the bar name.
class _BarName extends StatelessWidget {
  /// The bar.
  final Bar bar;

  /// Creates a new bar name widget instance.
  const _BarName({
    required this.bar,
  });

  @override
  Widget build(BuildContext context) => Text(bar.name);
}

/// Allows to display the bar address.
class _BarAddress extends StatelessWidget {
  /// The bar.
  final Bar bar;

  /// Creates a new bar address widget instance.
  const _BarAddress({
    required this.bar,
  });

  @override
  Widget build(BuildContext context) => (bar.address?.isEmpty ?? true) ? Text(translations.bars.details.address.empty) : Text(bar.address!);
}
