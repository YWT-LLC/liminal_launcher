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
                // Interlinked
                EzSwitchPair(
                  config,
                  text: 'Linked home lists',
                  tipper: 'The home list can be dark/light theme based too!',
                  valueKey: interlinkedKey,
                  canChange: (bool choice) async {
                    if (choice == false) return true;

                    final bool? keepDark = await showDialog(
                      context: context,
                      builder: (BuildContext dCon) => EzAlertDialog(
                        config,
                        title: const Text('Keep which layout?', textAlign: TextAlign.center),
                        actions: <Widget>[
                          EzMaterialAction(
                            config,
                            text: 'Dark',
                            onPressed: () => Navigator.of(dCon).pop(true),
                          ),
                          EzMaterialAction(
                            config,
                            text: 'Light',
                            onPressed: () => Navigator.of(dCon).pop(false),
                          ),
                          EzMaterialAction(
                            config,
                            text: 'Cancel',
                            onPressed: () => Navigator.of(dCon).pop(),
                          ),
                        ],
                        needsClose: false,
                      ),
                    ); // todo: add fancy line x line stuffs

                    if (keepDark != null) {
                      await appInfo.cloneMatrix(keepDark);
                      return true;
                    } else {
                      return false;
                    }
                  },
                ),
                config.spacer,

                // Home scroll hints
                EzSwitchPair(
                  config,
                  text: 'Home scroll hints',
                  tipper:
                      'If you have a lot of home lanes,\nthis will add scroll arrows when there is content off-screen.',
                  valueKey: homeHintsKey,
                ),
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
