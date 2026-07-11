/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

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

class AddFAB extends FloatingActionButton {
  AddFAB(EzCP config, void Function() onPressed, {super.key})
      : super(
          heroTag: 'add_app_FAB',
          onPressed: onPressed,
          tooltip: 'Add more home apps',
          child: EzIcon(config, Icons.add),
        );
}

class SettingsFAB extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final void Function() onPressed;

  const SettingsFAB(this.config, this.appInfo, this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) => MenuAnchor(
        builder: (_, MenuController c, __) => GestureDetector(
          onLongPress: () => toggleMenu(c),
          child: FloatingActionButton(
            heroTag: 'settings_FAB',
            onPressed: onPressed,
            child: EzIcon(config, Icons.settings),
          ),
        ),
        menuChildren: <Widget>[
          EzMenuButton(
            config,
            label: config.ezL10n.ssSaveConfig,
            icon: EzIcon(config, Icons.download),
            onPressed: () => EzCM.saveConfig(config, context: context),
          ),
          EzMenuButton(
            config,
            label: config.ezL10n.ssLoadConfig,
            icon: EzIcon(config, Icons.upload),
            onPressed: () =>
                ezConfigLoader(config, context: context, extra: appInfo.reloadFromStorage),
          ),
        ],
      );
}
