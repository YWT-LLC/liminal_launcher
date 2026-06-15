/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppListSettings extends StatelessWidget {
  final EzCP config;

  const AppListSettings(this.config, {super.key});

  @override
  Widget build(BuildContext context) => EzElevatedIconButton(
        config,
        label: 'App list',
        icon: EzIcon(config, Icons.list),
        onPressed: () => ezModal(
          config,
          context: context,
          builder: (_) {
            final AppInfoProvider appInfo = Provider.of<AppInfoProvider>(context);

            return ezModalScroll(
              config,
              children: <Widget>[
                // Feeling fancy?
                EzSwitchPair(
                  config,
                  text: 'Linked home lists',
                  valueKey: interlinkedKey,
                ), // TODO: can change => select which one is staying (re-use advanced `line x line`?)
                config.spacer,

                // Auto search
                EzSwitchPair(
                  config,
                  text: 'Auto-search the apps list',
                  valueKey: autoSearchKey,
                ),
                config.separator,

                // Swipe selectors
                EzTitledDivider(
                  Text(
                    'Quick launch',
                    textAlign: TextAlign.center,
                    style: config.titleStyle,
                  ),
                  height: 0,
                  margin: config.marginVal,
                ),
                EzNewLine(config.labelStyle),
                Text(
                  'Swipe left/right on the home screen (except when editing) to open the selected app.\nLong press to clear your selection.',
                  textAlign: TextAlign.center,
                  style: config.labelStyle,
                ),
                config.spacer,
                SwipeSelector(config, appInfo, left: true),
                config.spacer,
                SwipeSelector(config, appInfo, left: false),
                config.separator,
              ],
            );
          },
        ),
      );
}
