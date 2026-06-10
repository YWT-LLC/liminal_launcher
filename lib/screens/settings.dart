/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class SettingsScreen extends StatelessWidget {
  /// Optionally override the starting position
  final int? targetPass;

  const SettingsScreen({super.key, this.targetPass});

  @override
  Widget build(BuildContext context) {
    return Consumer<EzCP>(
      builder: (_, EzCP config, __) => LiminalScaffold(
        config,
        body: EzSettingsHub(
          config,
          pages: <EzSettingsSection>[
            // Global //

            EzSettingsSection(
              position: 0,
              title: config.ezL10n.gGlobal,
              icon: Icon(
                EzCM.onMobile
                    ? EzCM.platform == TargetPlatform.iOS
                        ? Icons.phone_iphone
                        : Icons.phone_android
                    : Icons.computer,
                semanticLabel: config.ezL10n.gGlobal,
              ),
              subSettings: <EzSubSetting>[],
              fromStorage: () => EzSubSetting.blank,
              build: (_) => EzGlobalSettings(
                config,
                resetTitle: () => config.ezL10n.ssResetAppearance,
                additionalSettings: <Widget>[
                  config.spacer,
                  AppListSettings(config),
                  config.spacer,
                  AppSecSettings(config),
                ],
                quickConfigSpacer: config.divider,
                extraBig: (bool updateBoth) async {
                  if (updateBoth || config.isDark) {
                    // Button design
                    await EzCM.setString(darkListLabelKey, LabelType.full.value);
                    await EzCM.setBool(darkListIconKey, true);
                    await EzCM.setBool(darkElevatedListKey, true);
                    await EzCM.setString(darkFolderLabelKey, LabelType.full.value);
                    await EzCM.setBool(darkFolderIconKey, true);
                    await EzCM.setBool(darkElevatedFolderKey, true);
                    await EzCM.setBool(darkWideTilesKey, true);

                    // Page design
                    await EzCM.setBool(darkHideStatusKey, false);
                    await EzCM.setBool(darkHomeTimeKey, true);
                    await EzCM.setString(darkHomeDateKey, DateType.long.value);
                    await EzCM.setString(darkHorizontalAlignKey,
                        config.isLefty ? ListAlignment.end.value : ListAlignment.start.value);
                    await EzCM.setString(darkVerticalAlignKey, ListAlignment.start.value);
                  }

                  if (updateBoth || !config.isDark) {
                    // Button design
                    await EzCM.setString(lightListLabelKey, LabelType.full.value);
                    await EzCM.setBool(lightListIconKey, true);
                    await EzCM.setBool(lightElevatedListKey, true);
                    await EzCM.setString(lightFolderLabelKey, LabelType.full.value);
                    await EzCM.setBool(lightFolderIconKey, true);
                    await EzCM.setBool(lightElevatedFolderKey, true);
                    await EzCM.setBool(lightWideTilesKey, true);

                    // Page design
                    await EzCM.setBool(lightHideStatusKey, false);
                    await EzCM.setBool(lightHomeTimeKey, true);
                    await EzCM.setString(lightHomeDateKey, DateType.long.value);
                    await EzCM.setString(lightHorizontalAlignKey,
                        config.isLefty ? ListAlignment.end.value : ListAlignment.start.value);
                    await EzCM.setString(lightVerticalAlignKey, ListAlignment.start.value);
                  }
                },
                extraVis: (bool updateBoth) async {
                  if (updateBoth || config.isDark) {
                    // Button design
                    await EzCM.setString(darkListLabelKey, LabelType.full.value);
                    await EzCM.setBool(darkListIconKey, true);
                    await EzCM.setBool(darkElevatedListKey, true);
                    await EzCM.setString(darkFolderLabelKey, LabelType.full.value);
                    await EzCM.setBool(darkFolderIconKey, false);
                    await EzCM.setBool(darkElevatedFolderKey, true);
                    await EzCM.setBool(darkWideTilesKey, true);

                    // Page design
                    await EzCM.setBool(darkHideStatusKey, true);
                    await EzCM.setBool(darkHomeTimeKey, true);
                    await EzCM.setString(darkHomeDateKey, DateType.medium.value);
                    await EzCM.setString(darkHorizontalAlignKey, ListAlignment.center.value);
                    await EzCM.setString(darkVerticalAlignKey, ListAlignment.start.value);
                  }

                  if (updateBoth || !config.isDark) {
                    // Button design
                    await EzCM.setString(lightListLabelKey, LabelType.full.value);
                    await EzCM.setBool(lightListIconKey, true);
                    await EzCM.setBool(lightElevatedListKey, true);
                    await EzCM.setString(lightFolderLabelKey, LabelType.full.value);
                    await EzCM.setBool(lightFolderIconKey, false);
                    await EzCM.setBool(lightElevatedFolderKey, true);
                    await EzCM.setBool(lightWideTilesKey, true);

                    // Page design
                    await EzCM.setBool(lightHideStatusKey, true);
                    await EzCM.setBool(lightHomeTimeKey, true);
                    await EzCM.setString(lightHomeDateKey, DateType.medium.value);
                    await EzCM.setString(lightHorizontalAlignKey, ListAlignment.center.value);
                    await EzCM.setString(lightVerticalAlignKey, ListAlignment.start.value);
                  }
                },
                extraChalk: (_) async {
                  // Button design
                  await EzCM.setString(darkListLabelKey, LabelType.full.value);
                  await EzCM.setBool(darkListIconKey, false);
                  await EzCM.setBool(darkElevatedListKey, false);
                  await EzCM.setString(darkFolderLabelKey, LabelType.full.value);
                  await EzCM.setBool(darkFolderIconKey, false);
                  await EzCM.setBool(darkElevatedFolderKey, false);
                  await EzCM.setBool(darkWideTilesKey, true);

                  // Page design
                  await EzCM.setBool(darkHideStatusKey, false);
                  await EzCM.setBool(darkHomeTimeKey, false);
                  await EzCM.setString(darkHomeDateKey, DateType.medium.value);
                  await EzCM.setString(darkHorizontalAlignKey, ListAlignment.center.value);
                  await EzCM.setString(darkVerticalAlignKey, ListAlignment.start.value);
                },
                extraNebula: (_) async {
                  // Button design
                  await EzCM.setString(darkListLabelKey, LabelType.initials.value);
                  await EzCM.setBool(darkListIconKey, true);
                  await EzCM.setBool(darkElevatedListKey, false);
                  await EzCM.setString(darkFolderLabelKey, LabelType.initials.value);
                  await EzCM.setBool(darkFolderIconKey, false);
                  await EzCM.setBool(darkElevatedFolderKey, true);
                  await EzCM.setBool(darkWideTilesKey, true);

                  // Page design
                  await EzCM.setBool(darkHideStatusKey, true);
                  await EzCM.setBool(darkHomeTimeKey, true);
                  await EzCM.setString(darkHomeDateKey, DateType.compact.value);
                  await EzCM.setString(darkHorizontalAlignKey,
                      config.isLefty ? ListAlignment.end.value : ListAlignment.start.value);
                  await EzCM.setString(darkVerticalAlignKey, ListAlignment.end.value);
                },
                extraWall: (_) async {
                  // Button design
                  await EzCM.setString(lightListLabelKey, LabelType.full.value);
                  await EzCM.setBool(lightListIconKey, true);
                  await EzCM.setBool(lightElevatedListKey, false);
                  await EzCM.setString(lightFolderLabelKey, LabelType.full.value);
                  await EzCM.setBool(lightFolderIconKey, true);
                  await EzCM.setBool(lightElevatedFolderKey, false);
                  await EzCM.setBool(lightWideTilesKey, true);

                  // Page design
                  await EzCM.setBool(lightHideStatusKey, false);
                  await EzCM.setBool(lightHomeTimeKey, true);
                  await EzCM.setString(lightHomeDateKey, DateType.long.value);
                  await EzCM.setString(lightHorizontalAlignKey,
                      config.isLefty ? ListAlignment.end.value : ListAlignment.start.value);
                  await EzCM.setString(lightVerticalAlignKey, ListAlignment.start.value);
                },
              ),
            ),

            // Color //

            EzSettingsSection(
              position: 1,
              title: config.ezL10n.gColor,
              icon: Icon(
                Icons.palette,
                semanticLabel: config.ezL10n.gColor,
              ),
              subSettings: <EzSubSetting>[
                EzSubSetting.qckColor,
                EzSubSetting.advColor,
              ],
              fromStorage: () => EzCM.get(advancedColorsKey) == true
                  ? EzSubSetting.advColor
                  : EzSubSetting.qckColor,
              build: (EzSubSetting subSec) => EzColorSettings(config, target: subSec),
            ),

            // Design //

            EzSettingsSection(
              position: 2,
              title: config.ezL10n.gDesign,
              icon: Icon(
                Icons.design_services,
                semanticLabel: config.ezL10n.gDesign,
              ),
              subSettings: <EzSubSetting>[
                EzSubSetting.butDesign,
                EzSubSetting.pagDesign,
              ],
              fromStorage: () =>
                  EzCM.get(pageTabKey) == true ? EzSubSetting.pagDesign : EzSubSetting.butDesign,
              build: (EzSubSetting subSec) => EzDesignSettings(
                config,
                target: subSec,
                prependButton: <Widget>[
                  // Tile settings
                  AppTileSetting(config, folder: false),
                  config.spacer,
                  AppTileSetting(config, folder: true),
                  config.separator,
                ],
                styleLabel: 'Elevated style',
                includeBackgroundImage: false,
                prependPage: <Widget>[
                  // Wallpaper
                  HeaderSettings(config),
                  config.spacer,

                  config.isDark
                      ? EzImageSetting(
                          config,
                          pathKey: darkBackgroundImageKey,
                          fitKey: darkBackgroundFitKey,
                          label: 'Wallpaper',
                          allowSolidColor: true,
                          clearLabel: 'Use OS',
                        )
                      : EzImageSetting(
                          config,
                          pathKey: lightBackgroundImageKey,
                          fitKey: lightBackgroundFitKey,
                          label: 'Wallpaper',
                          allowSolidColor: true,
                          clearLabel: 'Use OS',
                        ),
                  config.spacer,

                  // Page alignment
                  EzElevatedIconButton(
                    config,
                    onPressed: () async {
                      await ezModal(
                        config,
                        context: context,
                        builder: (_) => ezModalScroll(config, children: <Widget>[
                          AlignmentSelectors(config),
                          config.separator,
                        ]),
                      );

                      if (hAlign(config) !=
                              LAConfig.lookup(EzCM.get(config.isDark
                                  ? darkHorizontalAlignKey
                                  : lightHorizontalAlignKey)) ||
                          vAlign(config) !=
                              LAConfig.lookup(EzCM.get(
                                  config.isDark ? darkVerticalAlignKey : lightVerticalAlignKey))) {
                        await config.rebuildUI(<EzCacheType>{EzCacheType.design});
                      }
                    },
                    label: 'List alignment',
                    icon: const Icon(Icons.grid_3x3),
                  ),
                  config.separator,
                ],
              ),
            ),

            // Text //

            EzSettingsSection(
              position: 3,
              title: config.ezL10n.gText,
              icon: Icon(
                Icons.text_format,
                semanticLabel: config.ezL10n.gText,
              ),
              subSettings: <EzSubSetting>[
                EzSubSetting.qckText,
                EzSubSetting.advText,
              ],
              fromStorage: () =>
                  EzCM.get(advancedTextKey) == true ? EzSubSetting.advText : EzSubSetting.qckText,
              build: (EzSubSetting subSec) => EzTextSettings(config, target: subSec),
            ),
          ],
          target: targetPass,
        ),
        fabs: <Widget>[
          // Rebuild (conditional)
          if (config.needsRebuild) ...<Widget>[
            config.spacer,
            EzRebuildFAB(config),
          ],

          // Save/upload config
          config.spacer,
          EzConfigFAB(config),
        ],
      ),
    );
  }
}
