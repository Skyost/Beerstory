import 'dart:io';

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/database.dart';
import 'package:beerstory/model/settings/group_objects.dart';
import 'package:beerstory/model/settings/theme.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/platform.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// The scaffold body for the settings page.
class SettingsScaffoldBody extends StatelessWidget {
  /// Creates a new settings scaffold body instance.
  const SettingsScaffoldBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: kSpace),
        child: FTileGroup(
          label: Text(translations.settings.application.label),
          children: [
            _ChangeThemeTile(),
            _GroupObjectsTile(),
          ],
        ),
      ),
      if (currentPlatform != Platform.web)
        Padding(
          padding: const EdgeInsets.only(bottom: kSpace),
          child: FTileGroup(
            label: Text(translations.settings.data.label),
            children: [
              _BackupDataTile(),
              _RestoreDataTile(),
            ],
          ),
        ),
      FTileGroup(
        label: Text(translations.settings.about.label),
        children: [
          _AboutTile(),
        ],
      ),
    ],
  );
}

/// The tile that allows to change the theme.
class _ChangeThemeTile extends ConsumerStatefulWidget with FTileMixin {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChangeThemeTileState();
}

/// The change theme tile state.
class _ChangeThemeTileState extends ConsumerState<_ChangeThemeTile> with SingleTickerProviderStateMixin<_ChangeThemeTile> {
  /// The popover controller.
  late FPopoverController controller = FPopoverController(vsync: this);

  @override
  Widget build(BuildContext context) {
    AsyncValue<ThemeMode> theme = ref.watch(themeSettingsEntryProvider);
    return FPopoverMenu(
      popoverController: controller,
      menuAnchor: Alignment.topRight,
      childAnchor: Alignment.bottomRight,
      menu: [
        FItemGroup(
          children: [
            for (ThemeMode themeMode in ThemeMode.values)
              FItem(
                prefix: Icon(themeModeToIcon(themeMode)),
                title: Text(themeModeToString(themeMode)),
                onPress: () => changeThemeMode(themeMode),
              ),
          ],
        ),
      ],
      child: FTile(
        enabled: theme is AsyncData<ThemeMode>,
        title: Text(translations.settings.application.theme.title),
        subtitle: Text(themeModeToString(theme.value)),
        prefix: Icon(themeModeToIcon(theme.value)),
        suffix: const Icon(FIcons.chevronDown),
        onPress: controller.toggle,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Returns the string corresponding to the theme mode.
  String themeModeToString(ThemeMode? themeMode) => switch (themeMode) {
    ThemeMode.light => translations.settings.application.theme.subtitle.light,
    ThemeMode.dark => translations.settings.application.theme.subtitle.dark,
    ThemeMode.system || _ => translations.settings.application.theme.subtitle.system,
  };

  /// Returns the icon data corresponding to the theme mode.
  IconData themeModeToIcon(ThemeMode? themeMode) => switch (themeMode) {
    ThemeMode.light => FIcons.sun,
    ThemeMode.dark => FIcons.moon,
    ThemeMode.system || _ => FIcons.eclipse,
  };

  /// Changes the theme mode.
  void changeThemeMode(ThemeMode value) {
    ref.read(themeSettingsEntryProvider.notifier).changeValue(value);
    controller.toggle();
  }
}

/// The tile that allows to group the objects.
class _GroupObjectsTile extends ConsumerWidget with FTileMixin {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool? value = ref.watch(groupObjectsSettingsEntryProvider).value;
    void onPress([bool? newValue]) => ref.read(groupObjectsSettingsEntryProvider.notifier).changeValue(newValue ?? !value!);
    return FTile(
      title: Text(translations.settings.application.groupObjects.title),
      subtitle: Text(translations.settings.application.groupObjects.subtitle),
      prefix: const Icon(FIcons.arrowDownZA),
      suffix: FSwitch(
        value: value == true,
        onChange: onPress,
      ),
      enabled: value != null,
      onPress: onPress,
    );
  }
}

/// The tile that allows to backup the data.
class _BackupDataTile extends ConsumerWidget with FTileMixin {
  @override
  Widget build(BuildContext context, WidgetRef ref) => FTile(
    title: Text(translations.settings.data.backup.title),
    subtitle: Text(translations.settings.data.backup.subtitle),
    prefix: const Icon(FIcons.download),
    onPress: () async {
      try {
        String? backupFilePath = await showWaitingOverlay(
          context,
          future: (() async {
            Directory directory = await getApplicationDocumentsDirectory();
            return FilePicker.platform.saveFile(
              dialogTitle: translations.settings.data.backup.title,
              initialDirectory: directory.path,
              type: FileType.custom,
              allowedExtensions: ['db'],
              lockParentWindow: true,
            );
          })(),
        );
        if (backupFilePath == null || !context.mounted) {
          return;
        }
        if (!backupFilePath.endsWith('.db')) {
          backupFilePath += '.db';
        }
        await showWaitingOverlay(
          context,
          future: ref.read(databaseProvider).exportInto(File(backupFilePath)),
        );
        if (context.mounted) {
          showFToast(
            context: context,
            title: Text(translations.settings.data.backup.success),
          );
        }
      } catch (ex, stackTrace) {
        printError(ex, stackTrace);
        if (context.mounted) {
          showFToast(
            context: context,
            title: Text(translations.error.generic),
            style: (style) => style.copyWith(
              titleTextStyle: style.titleTextStyle.copyWith(
                color: context.theme.colors.error,
              ),
            ),
          );
        }
      }
    },
  );
}

/// The tile that allows to restore the data.
class _RestoreDataTile extends ConsumerWidget with FTileMixin {
  @override
  Widget build(BuildContext context, WidgetRef ref) => FTile(
    title: Text(translations.settings.data.restore.title),
    subtitle: Text(translations.settings.data.restore.subtitle),
    prefix: const Icon(FIcons.upload),
    onPress: () async {
      try {
        FilePickerResult? filePickerResult = await showWaitingOverlay(
          context,
          future: (() async {
            Directory directory = await getApplicationDocumentsDirectory();
            return FilePicker.platform.pickFiles(
              dialogTitle: translations.settings.data.restore.title,
              initialDirectory: directory.path,
              type: FileType.custom,
              allowedExtensions: ['db'],
              lockParentWindow: true,
            );
          })(),
        );
        String? backupFilePath = filePickerResult?.files.firstOrNull?.path;
        if (backupFilePath == null || !context.mounted) {
          return;
        }
        await showWaitingOverlay(
          context,
          future: ref.read(databaseProvider).importFrom(File(backupFilePath)),
        );
        if (context.mounted) {
          showFToast(
            context: context,
            title: Text(translations.settings.data.restore.success),
          );
        }
      } catch (ex, stackTrace) {
        printError(ex, stackTrace);
        if (context.mounted) {
          showFToast(
            context: context,
            title: Text(translations.error.generic),
            style: (style) => style.copyWith(
              titleTextStyle: style.titleTextStyle.copyWith(
                color: context.theme.colors.error,
              ),
            ),
          );
        }
      }
    },
  );
}

/// The tile that displays the about page.
class _AboutTile extends StatelessWidget with FTileMixin {
  @override
  Widget build(BuildContext context) => FTile(
    title: Text(translations.settings.about.about.title),
    prefix: const Icon(FIcons.info),
    onPress: () => launchUrlString('https://github.com/Skyost/Beerstory'),
    subtitle: FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        String version = snapshot.data?.version ?? '1.0.0';
        return Text('Beerstory v$version — By Skyost.');
      },
    ),
  );
}
