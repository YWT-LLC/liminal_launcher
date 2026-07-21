/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

// TODO: last: full (runtime) audit of alignment settings. needs work
//  ...double last: X-tuple check the canToggle vs toggle, make sure nothing got crossed

import '../utils/export.dart';
import '../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:open_ui/open_ui.dart';

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
              icon: EzIcon(
                config,
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
                  config.separator,
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
                    await EzCM.setBool(darkPagesKey, true);

                    // Page design
                    await EzCM.setBool(darkHideStatusKey, false);
                    await EzCM.setString(
                      darkHorizontalAlignKey,
                      config.isLefty ? ListAlignment.end.value : ListAlignment.start.value,
                    );
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
                    await EzCM.setBool(lightPagesKey, true);

                    // Page design
                    await EzCM.setBool(lightHideStatusKey, false);
                    await EzCM.setString(
                      lightHorizontalAlignKey,
                      config.isLefty ? ListAlignment.end.value : ListAlignment.start.value,
                    );
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
                    await EzCM.setBool(darkFolderIconKey, true);
                    await EzCM.setBool(darkElevatedFolderKey, true);

                    await EzCM.setBool(darkWideTilesKey, true);
                    await EzCM.setBool(darkPagesKey, true);

                    // Page design
                    await EzCM.setBool(darkHideStatusKey, true);
                    await EzCM.setString(darkHorizontalAlignKey, ListAlignment.center.value);
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
                    await EzCM.setBool(lightPagesKey, true);

                    // Page design
                    await EzCM.setBool(lightHideStatusKey, true);
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
                  await EzCM.setBool(darkPagesKey, true);

                  // Page design
                  await EzCM.setBool(darkHideStatusKey, true);
                  await EzCM.setString(darkHorizontalAlignKey, ListAlignment.center.value);
                  await EzCM.setString(darkVerticalAlignKey, ListAlignment.start.value);
                },
                extraNebula: (_) async {
                  // Button design
                  await EzCM.setString(darkListLabelKey, LabelType.none.value);
                  await EzCM.setBool(darkListIconKey, true);
                  await EzCM.setBool(darkElevatedListKey, false);
                  await EzCM.setString(darkFolderLabelKey, LabelType.none.value);
                  await EzCM.setBool(darkFolderIconKey, true);
                  await EzCM.setBool(darkElevatedFolderKey, false);

                  await EzCM.setBool(darkWideTilesKey, false);
                  await EzCM.setBool(darkPagesKey, false);

                  // Page design
                  await EzCM.setBool(darkHideStatusKey, true);
                  await EzCM.setString(
                    darkHorizontalAlignKey,
                    config.isLefty ? ListAlignment.end.value : ListAlignment.start.value,
                  );
                  await EzCM.setString(darkVerticalAlignKey, ListAlignment.start.value);
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
                  await EzCM.setBool(lightPagesKey, true);

                  // Page design
                  await EzCM.setBool(lightHideStatusKey, false);
                  await EzCM.setString(
                    lightHorizontalAlignKey,
                    config.isLefty ? ListAlignment.end.value : ListAlignment.start.value,
                  );
                  await EzCM.setString(lightVerticalAlignKey, ListAlignment.start.value);
                },
              ),
            ),

            // Color //
            EzSettingsSection(
              position: 1,
              title: config.ezL10n.gColor,
              icon: EzIcon(config, Icons.palette, semanticLabel: config.ezL10n.gColor),
              subSettings: <EzSubSetting>[EzSubSetting.qckColor, EzSubSetting.advColor],
              fromStorage: () => EzCM.get(advancedColorsKey) == true
                  ? EzSubSetting.advColor
                  : EzSubSetting.qckColor,
              build: (EzSubSetting subSec) => EzColorSettings(config, target: subSec),
            ),

            // Design //
            EzSettingsSection(
              position: 2,
              title: config.ezL10n.gDesign,
              icon: EzIcon(config, Icons.design_services, semanticLabel: config.ezL10n.gDesign),
              subSettings: <EzSubSetting>[EzSubSetting.butDesign, EzSubSetting.pagDesign],
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
                        builder: (_) => ezModalScroll(
                          config,
                          children: <Widget>[AlignmentSelectors(config), config.separator],
                        ),
                      );

                      if (horizontalAlign(config) !=
                              LAConfig.lookup(
                                EzCM.get(
                                  config.isDark ? darkHorizontalAlignKey : lightHorizontalAlignKey,
                                ),
                              ) ||
                          verticalAlign(config) !=
                              LAConfig.lookup(
                                EzCM.get(
                                  config.isDark ? darkVerticalAlignKey : lightVerticalAlignKey,
                                ),
                              )) {
                        await config.rebuildUI(<EzCacheType>{EzCacheType.design});
                      }
                    },
                    label: 'List alignment',
                    icon: EzIcon(config, Icons.grid_3x3),
                  ),
                  config.separator,

                  // Hide status bar
                  EzSwitchPair(
                    config,
                    text: 'Hide status bar',
                    valueKey: config.isDark ? darkHideStatusKey : lightHideStatusKey,
                    afterChanged: (bool? choice) async {
                      if (choice == null) return;
                      if (EzCM.updateBoth) {
                        await EzCM.setBool(
                          config.isDark ? lightHideStatusKey : darkHideStatusKey,
                          choice,
                        );
                      }

                      if (choice == true) {
                        await SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.manual,
                          overlays: <SystemUiOverlay>[SystemUiOverlay.bottom],
                        );
                      } else {
                        await SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.manual,
                          overlays: SystemUiOverlay.values,
                        );
                      }
                    },
                  ),
                  config.spacer,

                  // Use fullscreen pages
                  EzSwitchPair(
                    config,
                    text: 'Fullscreen home pages',
                    valueKey: config.isDark ? darkPagesKey : lightPagesKey,
                    afterChanged: (bool? choice) async {
                      if (choice == null) return;

                      if (EzCM.updateBoth) {
                        await EzCM.setBool(config.isDark ? lightPagesKey : darkPagesKey, choice);
                      }

                      await config.rebuildUI(<EzCacheType>{EzCacheType.design});
                    },
                  ),
                  config.separator,
                ],
              ),
            ),

            // Text //
            EzSettingsSection(
              position: 3,
              title: config.ezL10n.gText,
              icon: EzIcon(config, Icons.text_format, semanticLabel: config.ezL10n.gText),
              subSettings: <EzSubSetting>[EzSubSetting.qckText, EzSubSetting.advText],
              fromStorage: () =>
                  EzCM.get(advancedTextKey) == true ? EzSubSetting.advText : EzSubSetting.qckText,
              build: (EzSubSetting subSec) => EzTextSettings(config, target: subSec),
            ),
          ],
          target: targetPass,
        ),
        fabs: <Widget>[
          // Rebuild (conditional)
          if (config.needsRebuild) ...<Widget>[config.spacer, EzRebuildFAB(config)],

          // Save/upload config
          config.spacer,
          EzConfigFAB(config),
        ],
      ),
    );
  }
}
