/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../../utils/export.dart';
import './export.dart';

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

//* (Widget) Functions *//

Widget drawWidget(
  EzCP config, {
  required AppInfoProvider appInfo,
  required String typeString,
  required TileState state,
  required ValueNotifier<double>? rippleProgress,
  required void Function() editReset,
  required LimPos pos,
  required List<String> data,
}) =>
    switch (typeString) {
      esClock => ClockWidget(config, appInfo, state, pos, rippleProgress, editReset, data),
      esEvent => EventWidget(config, appInfo, state, pos, rippleProgress, editReset, data),
      esSearch => SearchWidget(config, appInfo, state, pos, rippleProgress, editReset, data),
      esTimer => TimerWidget(config, appInfo, state, pos, rippleProgress, editReset, data),
      esToggleMedia =>
        ToggleMediaWidget(config, appInfo, state, pos, rippleProgress, editReset, data),
      esThemeMode => ThemeModeWidget(config, appInfo, state, pos, rippleProgress, editReset, data),
      _ => const SizedBox.shrink(),
    };

//* Custom Classes *//

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
            label: config.ezL10n.gSystem,
            icon: EzIcon(config, Icons.settings),
            onPressed: () => openSystemSettings(),
          ),
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
            onPressed: () => ezConfigLoader(
              config,
              context: context,
              extra: () => appInfo.reloadFromStorage(config),
            ),
          ),
        ],
      );
}
