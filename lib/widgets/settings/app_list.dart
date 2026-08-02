/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppListSettings extends StatelessWidget {
  final EzCP config;

  const AppListSettings(this.config, {super.key});

  @override
  Widget build(BuildContext context) => EzElevatedIconButton(
        config,
        label: l10n(config).ssAppList,
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
                  text: l10n(config).ssLinkedList,
                  bigTipper: TextSpan(
                    children: <InlineSpan>[
                      EzPlainText(text: l10n(config).ssThemedHome, style: config.bodyStyle),
                      EzPlainText(text: '\n\n', style: config.bodyStyle),
                      EzPlainText(text: l10n(config).ssNoBothHome, style: config.bodyStyle),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: FaIcon(FontAwesomeIcons.yinYang, size: config.iconSize),
                      ),
                      EzPlainText(text: l10n(config).ssIndependent, style: config.bodyStyle),
                      EzPlainText(text: '\n\n', style: config.bodyStyle),
                      EzPlainText(text: l10n(config).ssRelinked, style: config.bodyStyle),
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
                        title: Text(l10n(config).ssKeepWhich, textAlign: TextAlign.center),
                        actions: <Widget>[
                          EzAction(
                            config,
                            text: config.ezL10n.gDark,
                            onPressed: () => Navigator.of(dCon).pop(true),
                          ),
                          EzAction(
                            config,
                            text: config.ezL10n.gLight,
                            onPressed: () => Navigator.of(dCon).pop(false),
                          ),
                          EzAction(
                            config,
                            text: config.ezL10n.gCancel,
                            onPressed: () => Navigator.of(dCon).pop(),
                          ),
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
                EzSwitchPair(
                  config,
                  text: l10n(config).ssHomeRipple,
                  valueKey: homeRippleKey,
                ),
                config.spacer,

                // List ripple
                EzSwitchPair(
                  config,
                  text: l10n(config).ssListRipple,
                  valueKey: listRippleKey,
                ),
                config.spacer,

                // Auto search
                EzSwitchPair(
                  config,
                  text: l10n(config).ssAutoSearch,
                  valueKey: autoSearchKey,
                ),
                config.separator,

                // Swipe selectors
                EzTitledDivider(
                  config,
                  title: Text(
                    l10n(config).ssQuickLaunch,
                    textAlign: TextAlign.center,
                    style: config.titleStyle,
                  ),
                  height: 0,
                ),
                EzNewLine(config.labelStyle),
                Text(
                  l10n(config).ssQLDescription,
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
