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

  SettingsScreen({this.targetPass}) : super(key: ValueKey<int>(EzConfig.seed));

  @override
  Widget build(BuildContext context) => Consumer<EzConfigProvider>(
        builder: (_, EzConfigProvider config, __) => LiminalScaffold(
          EzSettingsHub(
            pages: <EzSettingsSection>[
              // Global //

              EzSettingsSection(
                position: 0,
                title: EzConfig.l10n.gGlobal,
                icon: Icon(
                  config.onMobile
                      ? config.platform == TargetPlatform.iOS
                          ? Icons.phone_iphone
                          : Icons.phone_android
                      : Icons.computer,
                  semanticLabel: EzConfig.l10n.gGlobal,
                ),
                subSettings: <EzSubSetting>[],
                fromStorage: () => EzSubSetting.blank,
                build: (_) => EzGlobalSettings(
                  resetTitle: () => EzConfig.l10n.ssResetAppearance,
                  additionalSettings: <Widget>[
                    EzConfig.spacer,
                    AppListSettings(),
                  ],
                  quickConfigSpacer: EzConfig.divider,
                  extraBig: (bool updateBoth) async {
                    if (updateBoth || EzConfig.isDark) {
                      // Button design
                      await EzConfig.setString(darkListLabelTypeKey, LabelType.full.value);
                      await EzConfig.setBool(darkListIconKey, true);
                      await EzConfig.setBool(darkElevatedListKey, true);
                      await EzConfig.setString(darkFolderLabelTypeKey, LabelType.full.value);
                      await EzConfig.setBool(darkFolderIconKey, true);
                      await EzConfig.setBool(darkElevatedFolderKey, true);
                      await EzConfig.setBool(darkWideTilesKey, true);

                      // Page design
                      await EzConfig.setBool(darkHideStatusKey, false);
                      await EzConfig.setBool(darkHomeTimeKey, true);
                      await EzConfig.setString(darkHomeDateKey, DateType.long.value);
                      await EzConfig.setString(darkHorizontalAlignKey,
                          EzConfig.isLefty ? ListAlignment.end.value : ListAlignment.start.value);
                      await EzConfig.setString(darkVerticalAlignKey, ListAlignment.start.value);
                    }

                    if (updateBoth || !EzConfig.isDark) {
                      // Button design
                      await EzConfig.setString(lightListLabelTypeKey, LabelType.full.value);
                      await EzConfig.setBool(lightListIconKey, true);
                      await EzConfig.setBool(lightElevatedListKey, true);
                      await EzConfig.setString(lightFolderLabelTypeKey, LabelType.full.value);
                      await EzConfig.setBool(lightFolderIconKey, true);
                      await EzConfig.setBool(lightElevatedFolderKey, true);
                      await EzConfig.setBool(lightWideTilesKey, true);

                      // Page design
                      await EzConfig.setBool(lightHideStatusKey, false);
                      await EzConfig.setBool(lightHomeTimeKey, true);
                      await EzConfig.setString(lightHomeDateKey, DateType.long.value);
                      await EzConfig.setString(lightHorizontalAlignKey,
                          EzConfig.isLefty ? ListAlignment.end.value : ListAlignment.start.value);
                      await EzConfig.setString(lightVerticalAlignKey, ListAlignment.start.value);
                    }
                  },
                  extraVis: (bool updateBoth) async {
                    if (updateBoth || EzConfig.isDark) {
                      // Button design
                      await EzConfig.setString(darkListLabelTypeKey, LabelType.full.value);
                      await EzConfig.setBool(darkListIconKey, true);
                      await EzConfig.setBool(darkElevatedListKey, true);
                      await EzConfig.setString(darkFolderLabelTypeKey, LabelType.full.value);
                      await EzConfig.setBool(darkFolderIconKey, false);
                      await EzConfig.setBool(darkElevatedFolderKey, true);
                      await EzConfig.setBool(darkWideTilesKey, true);

                      // Page design
                      await EzConfig.setBool(darkHideStatusKey, true);
                      await EzConfig.setBool(darkHomeTimeKey, true);
                      await EzConfig.setString(darkHomeDateKey, DateType.medium.value);
                      await EzConfig.setString(darkHorizontalAlignKey, ListAlignment.center.value);
                      await EzConfig.setString(darkVerticalAlignKey, ListAlignment.start.value);
                    }

                    if (updateBoth || !EzConfig.isDark) {
                      // Button design
                      await EzConfig.setString(lightListLabelTypeKey, LabelType.full.value);
                      await EzConfig.setBool(lightListIconKey, true);
                      await EzConfig.setBool(lightElevatedListKey, true);
                      await EzConfig.setString(lightFolderLabelTypeKey, LabelType.full.value);
                      await EzConfig.setBool(lightFolderIconKey, false);
                      await EzConfig.setBool(lightElevatedFolderKey, true);
                      await EzConfig.setBool(lightWideTilesKey, true);

                      // Page design
                      await EzConfig.setBool(lightHideStatusKey, true);
                      await EzConfig.setBool(lightHomeTimeKey, true);
                      await EzConfig.setString(lightHomeDateKey, DateType.medium.value);
                      await EzConfig.setString(lightHorizontalAlignKey, ListAlignment.center.value);
                      await EzConfig.setString(lightVerticalAlignKey, ListAlignment.start.value);
                    }
                  },
                  extraChalk: (_) async {
                    // Button design
                    await EzConfig.setString(darkListLabelTypeKey, LabelType.full.value);
                    await EzConfig.setBool(darkListIconKey, false);
                    await EzConfig.setBool(darkElevatedListKey, false);
                    await EzConfig.setString(darkFolderLabelTypeKey, LabelType.full.value);
                    await EzConfig.setBool(darkFolderIconKey, false);
                    await EzConfig.setBool(darkElevatedFolderKey, false);
                    await EzConfig.setBool(darkWideTilesKey, true);

                    // Page design
                    await EzConfig.setBool(darkHideStatusKey, false);
                    await EzConfig.setBool(darkHomeTimeKey, false);
                    await EzConfig.setString(darkHomeDateKey, DateType.medium.value);
                    await EzConfig.setString(darkHorizontalAlignKey, ListAlignment.center.value);
                    await EzConfig.setString(darkVerticalAlignKey, ListAlignment.start.value);
                  },
                  extraNebula: (_) async {
                    // Button design
                    await EzConfig.setString(darkListLabelTypeKey, LabelType.none.value);
                    await EzConfig.setBool(darkListIconKey, true);
                    await EzConfig.setBool(darkElevatedListKey, false);
                    await EzConfig.setString(darkFolderLabelTypeKey, LabelType.initials.value);
                    await EzConfig.setBool(darkFolderIconKey, false);
                    await EzConfig.setBool(darkElevatedFolderKey, true);
                    await EzConfig.setBool(darkWideTilesKey, true);

                    // Page design
                    await EzConfig.setBool(darkHideStatusKey, true);
                    await EzConfig.setBool(darkHomeTimeKey, true);
                    await EzConfig.setString(darkHomeDateKey, DateType.compact.value);
                    await EzConfig.setString(darkHorizontalAlignKey,
                        EzConfig.isLefty ? ListAlignment.end.value : ListAlignment.start.value);
                    await EzConfig.setString(darkVerticalAlignKey, ListAlignment.end.value);
                  },
                  extraWall: (_) async {
                    // Button design
                    await EzConfig.setString(lightListLabelTypeKey, LabelType.full.value);
                    await EzConfig.setBool(lightListIconKey, true);
                    await EzConfig.setBool(lightElevatedListKey, false);
                    await EzConfig.setString(lightFolderLabelTypeKey, LabelType.full.value);
                    await EzConfig.setBool(lightFolderIconKey, true);
                    await EzConfig.setBool(lightElevatedFolderKey, false);
                    await EzConfig.setBool(lightWideTilesKey, true);

                    // Page design
                    await EzConfig.setBool(lightHideStatusKey, false);
                    await EzConfig.setBool(lightHomeTimeKey, true);
                    await EzConfig.setString(lightHomeDateKey, DateType.long.value);
                    await EzConfig.setString(lightHorizontalAlignKey,
                        EzConfig.isLefty ? ListAlignment.end.value : ListAlignment.start.value);
                    await EzConfig.setString(lightVerticalAlignKey, ListAlignment.start.value);
                  },
                ),
              ),

              // Color //

              EzSettingsSection(
                position: 1,
                title: EzConfig.l10n.gColor,
                icon: Icon(
                  Icons.palette,
                  semanticLabel: EzConfig.l10n.gColor,
                ),
                subSettings: <EzSubSetting>[
                  EzSubSetting.qckColor,
                  EzSubSetting.advColor,
                ],
                fromStorage: () => EzConfig.get(advancedColorsKey) == true
                    ? EzSubSetting.advColor
                    : EzSubSetting.qckColor,
                build: (EzSubSetting subSec) => EzColorSettings(target: subSec),
              ),

              // Design //

              EzSettingsSection(
                position: 2,
                title: EzConfig.l10n.gDesign,
                icon: Icon(
                  Icons.design_services,
                  semanticLabel: EzConfig.l10n.gDesign,
                ),
                subSettings: <EzSubSetting>[
                  EzSubSetting.butDesign,
                  EzSubSetting.pagDesign,
                ],
                fromStorage: () => EzConfig.get(pageTabKey) == true
                    ? EzSubSetting.pagDesign
                    : EzSubSetting.butDesign,
                build: (EzSubSetting subSec) => EzDesignSettings(
                  target: subSec,
                  prependButton: <Widget>[
                    // Tile settings
                    const AppTileSetting(folder: false),
                    EzConfig.spacer,
                    const AppTileSetting(folder: true),
                    EzConfig.separator,
                  ],
                  styleLabel: 'Elevated style',
                  includeBackgroundImage: false,
                  prependPage: <Widget>[
                    // Wallpaper
                    const HeaderSettings(),
                    EzConfig.spacer,

                    EzConfig.isDark
                        ? const EzImageSetting(
                            pathKey: darkBackgroundImageKey,
                            fitKey: darkBackgroundFitKey,
                            label: 'Wallpaper',
                            allowSolidColor: true,
                            clearLabel: 'Use OS',
                          )
                        : const EzImageSetting(
                            pathKey: lightBackgroundImageKey,
                            fitKey: lightBackgroundFitKey,
                            label: 'Wallpaper',
                            allowSolidColor: true,
                            clearLabel: 'Use OS',
                          ),
                    EzConfig.spacer,

                    // Page alignment
                    EzElevatedIconButton(
                      onPressed: () async {
                        await ezModal(
                          context: context,
                          builder: (_) => ezModalScroll(<Widget>[
                            const AlignmentSelectors(),
                            EzConfig.separator,
                          ]),
                        );

                        if (hAlign !=
                                LAConfig.lookup(EzConfig.get(EzConfig.isDark
                                    ? darkHorizontalAlignKey
                                    : lightHorizontalAlignKey)) ||
                            vAlign !=
                                LAConfig.lookup(EzConfig.get(EzConfig.isDark
                                    ? darkVerticalAlignKey
                                    : lightVerticalAlignKey))) {
                          await EzConfig.rebuildUI();
                        }
                      },
                      label: 'List alignment',
                      icon: const Icon(Icons.grid_3x3),
                    ),
                    EzConfig.separator,
                  ],
                ),
              ),

              // Text //

              EzSettingsSection(
                position: 3,
                title: EzConfig.l10n.gText,
                icon: Icon(
                  Icons.text_format,
                  semanticLabel: EzConfig.l10n.gText,
                ),
                subSettings: <EzSubSetting>[
                  EzSubSetting.qckText,
                  EzSubSetting.advText,
                ],
                fromStorage: () => EzConfig.get(advancedTextKey) == true
                    ? EzSubSetting.advText
                    : EzSubSetting.qckText,
                build: (EzSubSetting subSec) => EzTextSettings(target: subSec),
              ),
            ],
            target: targetPass,
          ),
          fabs: <Widget>[
            // Rebuild (conditional)
            if (config.needsRebuild) ...<Widget>[
              config.layout.spacer,
              const EzRebuildFAB(),
            ],

            // Save/upload config
            config.layout.spacer,
            const EzConfigFAB(),
          ],
        ),
      );
}
