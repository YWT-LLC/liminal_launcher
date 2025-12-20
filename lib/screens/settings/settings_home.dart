/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:after_layout/after_layout.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SettingsHomeScreen extends StatefulWidget {
  const SettingsHomeScreen({super.key});

  @override
  State<SettingsHomeScreen> createState() => _SettingsHomeScreenState();
}

class _SettingsHomeScreenState extends State<SettingsHomeScreen>
    with AfterLayoutMixin<SettingsHomeScreen> {
  // Gather the fixed theme data //

  final bool isLefty = EzConfig.get(isLeftyKey);

  late final EFUILang el10n = ezL10n(context);

  // Define the build data //

  late final AppInfoProvider appProvider =
      Provider.of<AppInfoProvider>(context);

  bool resetAll = false;

  // Define custom functions //

  Future<dynamic> showTips() => showPlatformDialog(
        context: context,
        builder: (_) => const EzAlertDialog(
          title: Text('Tips', textAlign: TextAlign.center),
          content: Text('&& tricks', textAlign: TextAlign.center),
        ),
      );

  // Init //

  @override
  void afterFirstLayout(BuildContext context) async {
    if (!(await isGPlayInstall()) &&
        !EzConfig.get(shownReminderKey) &&
        context.mounted) {
      final TextStyle? style = Theme.of(context).textTheme.bodyLarge;

      await showPlatformDialog(
        context: context,
        builder: (_) => EzAlertDialog(
          title: const Text(
            'Welcome to Liminal Launcher',
            textAlign: TextAlign.center,
          ),
          content: EzRichText(
            <InlineSpan>[
              const EzPlainText(
                text:
                    '''We hope it serves you well! This version is not from the Play Store, so it should have been free.
Rest assured, the free version of Liminal will always be identical to the Google Play version.

With that said, if you want to support Liminal's development, or the development of more Empathetech software, please consider ''',
              ),
              EzInlineLink(
                'contributing',
                style: style,
                textAlign: TextAlign.center,
                url: Uri.parse('https://www.empathetech.net/#/contribute'),
                hint: 'Open a link to the Empathetic contribution options.',
              ),
              const EzPlainText(
                text: '''.

This is the only non-tutorial dialog that will appear.
And it will not appear again.

Thank you, and enjoy!''',
              ),
            ],
            style: style,
            textBackground: false,
            textAlign: TextAlign.center,
          ),
        ),
      );
      await EzConfig.setBool(shownReminderKey, true);
    }
  }

  //* Return the build *//

  @override
  Widget build(BuildContext context) {
    const EzSpacer ezSpacer = EzSpacer();

    return LiminalScaffold(
      EzScrollView(children: <Widget>[
        // TODO: New home for showTips

        // Navigation //

        // Color
        EzElevatedIconButton(
          onPressed: () => context.goNamed(colorSettingsPath),
          icon: EzIcon(Icons.navigate_next),
          label: el10n.csPageTitle,
        ),
        ezSpacer,

        // Design
        EzElevatedIconButton(
          onPressed: () => context.goNamed(designSettingsPath),
          icon: EzIcon(Icons.navigate_next),
          label: el10n.dsPageTitle,
        ),
        ezSpacer,

        // Launcher
        EzElevatedIconButton(
          onPressed: () => context.goNamed(launcherSettingsPath),
          icon: EzIcon(Icons.navigate_next),
          label: 'Launcher settings',
        ),
        ezSpacer,

        // Layout
        EzElevatedIconButton(
          onPressed: () => context.goNamed(layoutSettingsPath),
          icon: EzIcon(Icons.navigate_next),
          label: el10n.lsPageTitle,
        ),
        ezSpacer,

        // Text
        EzElevatedIconButton(
          onPressed: () => context.goNamed(textSettingsPath),
          icon: EzIcon(Icons.navigate_next),
          label: el10n.tsPageTitle,
        ),
        const EzDivider(),

        // Batch //

        const EzQuickConfig(),
        ezSpacer,

        // Randomize
        EzConfigRandomizer(
          onConfirm: () async {
            final bool isDark = isDarkTheme(context);

            late final String homeTimeKey;
            late final String homeDateKey;
            late final String listIconKey;
            late final String listLabelTypeKey;
            late final String folderIconKey;
            late final String folderLabelTypeKey;
            late final String homeHAlignKey;
            late final String homeVAlignKey;
            late final String listHAlignKey;
            late final String listVAlignKey;

            if (isDark) {
              homeTimeKey = darkHomeTimeKey;
              homeDateKey = darkHomeDateKey;
              listIconKey = darkListIconKey;
              listLabelTypeKey = darkListLabelTypeKey;
              folderIconKey = darkFolderIconKey;
              folderLabelTypeKey = darkFolderLabelTypeKey;
              homeHAlignKey = darkHomeHAlignKey;
              homeVAlignKey = darkHomeVAlignKey;
              listHAlignKey = darkListHAlignKey;
              listVAlignKey = darkListVAlignKey;
            } else {
              homeTimeKey = lightHomeTimeKey;
              homeDateKey = lightHomeDateKey;
              listIconKey = lightListIconKey;
              listLabelTypeKey = lightListLabelTypeKey;
              folderIconKey = lightFolderIconKey;
              folderLabelTypeKey = lightFolderLabelTypeKey;
              homeHAlignKey = lightHomeHAlignKey;
              homeVAlignKey = lightHomeVAlignKey;
              listHAlignKey = lightListHAlignKey;
              listVAlignKey = lightListVAlignKey;
            }

            await EzConfig.randomize(isDark, shiny: false);
            final Random random = Random();

            // Design
            await EzConfig.setBool(homeTimeKey, random.nextBool());
            await EzConfig.setBool(homeDateKey, random.nextBool());

            await EzConfig.setBool(listIconKey, random.nextBool());
            final int listLabelRand = random.nextInt(4);
            late final String listLabelValue;
            switch (listLabelRand) {
              case 0:
                listLabelValue = LabelType.none.configValue;
                break;
              case 1:
                listLabelValue = LabelType.initials.configValue;
                break;
              case 3:
                listLabelValue = LabelType.wingding.configValue;
                break;
              default:
                listLabelValue = LabelType.full.configValue;
                break;
            }
            await EzConfig.setString(listLabelTypeKey, listLabelValue);

            await EzConfig.setBool(folderIconKey, random.nextBool());
            final int folderLabelRand = random.nextInt(3);
            late final String folderLabelValue;
            switch (folderLabelRand) {
              case 0:
                folderLabelValue = LabelType.none.configValue;
                break;
              case 1:
                folderLabelValue = LabelType.initials.configValue;
                break;
              case 3:
                folderLabelValue = LabelType.wingding.configValue;
              default:
                folderLabelValue = LabelType.full.configValue;
                break;
            }
            await EzConfig.setString(folderLabelTypeKey, folderLabelValue);

            // Layout
            final int homeHAlignRand = random.nextInt(3);
            late final String homeHAlignValue;
            switch (homeHAlignRand) {
              case 0:
                homeHAlignValue = ListAlignment.start.configValue;
                break;
              case 2:
                homeHAlignValue = ListAlignment.end.configValue;
                break;
              default:
                homeHAlignValue = ListAlignment.center.configValue;
                break;
            }
            await EzConfig.setString(homeHAlignKey, homeHAlignValue);

            final int homeVAlignRand = random.nextInt(3);
            late final String homeVAlignValue;
            switch (homeVAlignRand) {
              case 0:
                homeVAlignValue = ListAlignment.start.configValue;
                break;
              case 2:
                homeVAlignValue = ListAlignment.end.configValue;
                break;
              default:
                homeVAlignValue = ListAlignment.center.configValue;
                break;
            }
            await EzConfig.setString(homeVAlignKey, homeVAlignValue);

            final int listHAlignRand = random.nextInt(3);
            late final String listHAlignValue;
            switch (listHAlignRand) {
              case 0:
                listHAlignValue = ListAlignment.start.configValue;
                break;
              case 2:
                listHAlignValue = ListAlignment.end.configValue;
                break;
              default:
                listHAlignValue = ListAlignment.center.configValue;
                break;
            }
            await EzConfig.setString(listHAlignKey, listHAlignValue);

            final int listVAlignRand = random.nextInt(3);
            late final String listVAlignValue;
            switch (listVAlignRand) {
              case 0:
                listVAlignValue = ListAlignment.start.configValue;
                break;
              case 2:
                listVAlignValue = ListAlignment.end.configValue;
                break;
              default:
                listVAlignValue = ListAlignment.center.configValue;
                break;
            }
            await EzConfig.setString(listVAlignKey, listVAlignValue);
          },
          extraKeys: extraSaveKeys,
          appName: appName,
          androidPackage: androidPackage,
        ),
        ezSpacer,

        // Reset
        EzElevatedIconButton(
          onPressed: () => showPlatformDialog(
            context: context,
            builder: (_) => StatefulBuilder(builder: (
              BuildContext dContext,
              StateSetter dialogState,
            ) {
              late final List<Widget> materialActions;
              late final List<Widget> cupertinoActions;

              (materialActions, cupertinoActions) = ezActionPairs(
                context: context,
                onConfirm: () async {
                  await EzConfig.reset(
                      skip: resetAll ? neverResetKeys : defaultNoResetKeys);
                  if (resetAll) await appProvider.reset();
                  if (dContext.mounted) Navigator.of(dContext).pop();
                },
                confirmIsDestructive: true,
                onDeny: () => Navigator.of(dContext).pop(),
              );

              return EzAlertDialog(
                key: ValueKey<bool>(resetAll),
                title: const Text(
                  'Reset all appearance settings?',
                  textAlign: TextAlign.center,
                ),
                content: SizedBox(
                  width: widthOf(context),
                  child: EzScrollView(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      EzSwitchPair(
                        text: 'Or, ALL settings',
                        value: resetAll,
                        onChanged: (bool? choice) {
                          resetAll = (choice == null) ? false : choice;
                          setState(() {});
                          dialogState(() {});
                        },
                      ),
                      ezSpacer,
                      ezRichUndoWarning(
                        context,
                        standalone: false,
                        extraKeys: extraSaveKeys,
                        appName: appName,
                        androidPackage: androidPackage,
                      ),
                    ],
                  ),
                ),
                materialActions: materialActions,
                cupertinoActions: cupertinoActions,
                needsClose: false,
              );
            }),
          ),
          icon: EzIcon(PlatformIcons(context).refresh),
          label: el10n.gResetAll,
        ),
        const EzSeparator(),
      ]),
      fabs: settingsFABs(context, home: true),
    );
  }
}
