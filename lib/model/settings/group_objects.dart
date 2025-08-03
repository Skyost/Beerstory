import 'package:beerstory/model/settings/entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The group objects settings entry provider.
final groupObjectsSettingsEntryProvider = AsyncNotifierProvider.autoDispose<GroupObjectsSettingsEntry, bool>(GroupObjectsSettingsEntry.new);

/// A settings entry that allows to group the objects.
class GroupObjectsSettingsEntry extends SettingsEntry<bool> {
  /// Creates a new group objects settings entry instance.
  GroupObjectsSettingsEntry()
    : super(
        key: 'groupObjects',
        defaultValue: false,
      );
}
