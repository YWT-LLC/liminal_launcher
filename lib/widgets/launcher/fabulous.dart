/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

const EzUpdaterFAB updater = EzUpdaterFAB(
  appVersion: '1.0.0',
  versionSource:
      'https://raw.githubusercontent.com/Empathetech-LLC/liminal_launcher/refs/heads/main/APP_VERSION',
  gPlay: 'blarg',
  appStore: 'blarg',
  github: 'https://github.com/Empathetech-LLC/liminal_launcher/releases',
);

class AddAppFAB extends FloatingActionButton {
  AddAppFAB(void Function() onPressed, {super.key})
      : super(
          heroTag: 'add_app_fab',
          onPressed: onPressed,
          tooltip: 'Add more home apps',
          child: EzIcon(Icons.add),
        );
}

class AddFolderFAB extends FloatingActionButton {
  AddFolderFAB(void Function() onPressed, {super.key})
      : super(
          heroTag: 'add_folder_fab',
          onPressed: onPressed,
          tooltip: 'Add an app folder',
          child: EzIcon(Icons.create_new_folder),
        );
}

class SettingsFAB extends FloatingActionButton {
  SettingsFAB(void Function() onPressed, {super.key})
      : super(
          heroTag: 'settings_fab',
          onPressed: onPressed,
          tooltip: EzConfig.l10n.ssNavHint,
          child: EzIcon(Icons.settings),
        );
}
