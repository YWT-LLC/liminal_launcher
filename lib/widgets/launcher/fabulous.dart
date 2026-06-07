/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

EzUpdaterFAB updater(EzCP config) => EzUpdaterFAB(
      config,
      appVersion: '1.0.0',
      versionSource:
          'https://raw.githubusercontent.com/Empathetech-LLC/liminal_launcher/refs/heads/main/APP_VERSION',
      gPlay: 'https://play.google.com/store/apps/details?id=net.empathetech.liminal_launcher',
      github: 'https://github.com/Empathetech-LLC/liminal_launcher/releases',
    );

class AddAppFAB extends FloatingActionButton {
  AddAppFAB(EzCP config, void Function() onPressed, {super.key})
      : super(
          heroTag: 'add_app_fab',
          onPressed: onPressed,
          tooltip: 'Add more home apps',
          child: EzIcon(Icons.add),
        );
}

class AddFolderFAB extends FloatingActionButton {
  AddFolderFAB(EzCP config, void Function() onPressed, {super.key})
      : super(
          heroTag: 'add_folder_fab',
          onPressed: onPressed,
          tooltip: 'Add an app folder',
          child: EzIcon(Icons.create_new_folder),
        );
}

class SettingsFAB extends FloatingActionButton {
  SettingsFAB(EzCP config, void Function() onPressed, {super.key})
      : super(
          heroTag: 'settings_fab',
          onPressed: onPressed,
          tooltip: config.efuiL10n.ssNavHint,
          child: EzIcon(Icons.settings),
        );
}
