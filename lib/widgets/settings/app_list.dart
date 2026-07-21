/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_ui/open_ui.dart';

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
              bigTipper: TextSpan(
                children: <InlineSpan>[
                  EzPlainText(
                    text: 'The home list can be dark/light theme based too!',
                    style: config.bodyStyle,
                  ),
                  EzPlainText(text: '\n\n', style: config.bodyStyle),
                  EzPlainText(
                    text: 'Note that the home page(s) have no update both system (',
                    style: config.bodyStyle,
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: FaIcon(FontAwesomeIcons.yinYang, size: config.iconSize),
                  ),
                  EzPlainText(text: '). The lists will be independent.', style: config.bodyStyle),
                  EzPlainText(text: '\n\n', style: config.bodyStyle),
                  EzPlainText(
                    text: 'If/when re-linked, you will be asked which version to keep.',
                    style: config.bodyStyle,
                  ),
                ],
                style: config.bodyStyle,
              ),
              valueKey: interlinkedKey,
              canChange: (bool choice) async {
                if (choice == false) return true;

                final bool? keepDark = await showDialog(
                  context: context,
                  builder: (BuildContext dCon) => EzAlertDialog(
                    config,
                    title: const Text('Keep which layout?', textAlign: TextAlign.center),
                    actions: <Widget>[
                      EzAction(config, text: 'Dark', onPressed: () => Navigator.of(dCon).pop(true)),
                      EzAction(
                        config,
                        text: 'Light',
                        onPressed: () => Navigator.of(dCon).pop(false),
                      ),
                      EzAction(config, text: 'Cancel', onPressed: () => Navigator.of(dCon).pop()),
                    ],
                    needsClose: false,
                  ),
                );

                if (keepDark != null) {
                  await appInfo.cloneMatrix(keepDark);
                  return true;
                } else {
                  return false;
                }
              },
            ),
            config.spacer,

            // Home ripple
            EzSwitchPair(config, text: 'Home ripple animation', valueKey: homeRippleKey),
            config.spacer,

            // List ripple
            EzSwitchPair(config, text: 'List ripple animation', valueKey: listRippleKey),
            config.spacer,

            // Auto search
            EzSwitchPair(config, text: 'Auto-search the apps list', valueKey: autoSearchKey),
            config.separator,

            // Swipe selectors
            EzTitledDivider(
              Text('Quick launch', textAlign: TextAlign.center, style: config.titleStyle),
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
