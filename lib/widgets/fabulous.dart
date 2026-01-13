/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AddAppFAB extends FloatingActionButton {
  /// [FloatingActionButton] that opens a modal for adding more home apps
  AddAppFAB(BuildContext context, void Function()? onPressed, {super.key})
      : super(
          heroTag: 'add_app_fab',
          onPressed: onPressed,
          tooltip: 'Add more home apps',
          child: EzIcon(PlatformIcons(context).add),
        );
}

class AddFolderFAB extends FloatingActionButton {
  /// [FloatingActionButton] that adds another home folder
  AddFolderFAB(BuildContext context, void Function()? onPressed, {super.key})
      : super(
          heroTag: 'add_folder_fab',
          onPressed: onPressed,
          tooltip: 'Add an app folder',
          child: EzIcon(Icons.create_new_folder),
        );
}

class SettingsFAB extends FloatingActionButton {
  /// [FloatingActionButton] that will go to the [SettingsHomeScreen]
  SettingsFAB(BuildContext context, void Function()? onPressed, {super.key})
      : super(
          heroTag: 'settings_fab',
          onPressed: onPressed,
          tooltip: EzConfig.l10n.ssNavHint,
          child: EzIcon(PlatformIcons(context).settings),
        );
}

const EzUpdaterFAB updater = EzUpdaterFAB(
  appVersion: '1.0.0',
  versionSource:
      'https://raw.githubusercontent.com/Empathetech-LLC/liminal_launcher/refs/heads/main/APP_VERSION',
  gPlay: 'blarg',
  appStore: 'blarg',
  github: 'https://github.com/Empathetech-LLC/liminal_launcher/releases',
);
