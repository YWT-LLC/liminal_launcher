/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../../utils/export.dart';
import './export.dart';
import 'package:ywt_private/ywt_private.dart' as ywt;

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

//* (Widget) Functions *//

Widget drawWidget(
  EzCP config, {
  required AppInfoProvider appInfo,
  required String typeString,
  required TileState state,
  required ValueNotifier<double>? rippleProgress,
  required LimPos pos,
  required List<String> data,
}) =>
    wideTiles(config)
        ? Container(
            width: double.infinity,
            alignment: pos.subAlign,
            child: switch (typeString) {
              esClock => ClockWidget(config, appInfo, state, rippleProgress, pos, data),
              esEvent => EventWidget(config, appInfo, state, rippleProgress, pos, data),
              esSearch => SearchWidget(config, appInfo, state, rippleProgress, pos, data),
              esTimer => TimerWidget(config, appInfo, state, rippleProgress, pos, data),
              esToggleMedia => ToggleMediaWidget(config, appInfo, state, rippleProgress, pos, data),
              esThemeMode => ThemeModeWidget(config, appInfo, state, rippleProgress, pos, data),
              _ => const SizedBox.shrink(),
            },
          )
        : switch (typeString) {
            esClock => ClockWidget(config, appInfo, state, rippleProgress, pos, data),
            esEvent => EventWidget(config, appInfo, state, rippleProgress, pos, data),
            esSearch => SearchWidget(config, appInfo, state, rippleProgress, pos, data),
            esTimer => TimerWidget(config, appInfo, state, rippleProgress, pos, data),
            esToggleMedia => ToggleMediaWidget(config, appInfo, state, rippleProgress, pos, data),
            esThemeMode => ThemeModeWidget(config, appInfo, state, rippleProgress, pos, data),
            _ => const SizedBox.shrink(),
          };

/// When [options] is true, [context] is required
Widget liminalFooter(
  EzCP config, {
  required bool textBackground,
  TextAlign textAlign = TextAlign.center,
  bool options = false,
  BuildContext? context,
  bool human = false,
  double? spacing,
}) =>
    EzFooter(
      config,
      message: EzRichText(
        config,
        children: <InlineSpan>[
          EzPlainText(
            text: l10n(config).gMachineTranslated,
            style: config.labelStyle,
          ),
          EzInlineLink(
            config,
            text: l10n(config).gTranslations,
            url: options ? null : Uri.parse('${ywt.ywtGitHub}/liminal_launcher/tree/main/lib/l10n'),
            onTap: options
                ? () => showDialog(
                      context: context!,
                      builder: (_) => EzAlertDialog(
                        config,
                        title: Text(l10n(config).gFix, textAlign: TextAlign.center),
                        actions: <Widget>[
                          EzAction(
                            config,
                            text: l10n(config).gLauncherEntries,
                            onPressed: () => launchUrl(
                                Uri.parse('${ywt.ywtGitHub}/liminal_launcher/tree/main/lib/l10n')),
                            semantics: config.ezL10n.gOpenLink,
                          ),
                          EzAction(
                            config,
                            text: l10n(config).gSettingsEntries,
                            onPressed: () => launchUrl(
                                Uri.parse('${ywt.ywtGitHub}/open_ui/tree/main/lib/src/l10n')),
                            semantics: config.ezL10n.gOpenLink,
                          ),
                          EzAction(
                            config,
                            text: config.ezL10n.gCancel,
                            onPressed: () => Navigator.of(context).pop(),
                            semantics: config.ezL10n.gOpenLink,
                          ),
                        ],
                      ),
                    )
                : null,
            hint: config.ezL10n.gOpenLink,
            style: config.labelStyle,
            textAlign: textAlign,
          ),
        ],
        textAlign: textAlign,
        textBackground: textBackground,
        style: config.labelStyle,
      ),
      human: human,
      spacing: spacing,
    );

EzUpdaterFAB updater(EzCP config) => EzUpdaterFAB(
      config,
      appVersion: '1.0.0',
      versionSource:
          'https://raw.githubusercontent.com/YWT-LLC/liminal_launcher/refs/heads/main/APP_VERSION',
      gPlay: 'https://play.google.com/store/apps/details?id=llc.ywt.liminal_launcher',
      github: 'https://github.com/YWT-LLC/liminal_launcher/releases',
    );

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
            onPressed: () =>
                ezConfigLoader(config, context: context, extra: appInfo.reloadFromStorage),
          ),
        ],
      );
}
