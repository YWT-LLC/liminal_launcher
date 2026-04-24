/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  /// Optionally override the starting position
  final int? targetPass;

  /// Optionally override the starting sub-page to advanced (or equivalent)
  final bool? advancedPass;

  AppearanceSettingsScreen({this.targetPass, this.advancedPass})
      : super(key: ValueKey<int>(EzConfig.seed));

  @override
  Widget build(BuildContext context) {
    return Consumer<EzConfigProvider>(
      builder: (_, EzConfigProvider config, __) => LiminalScaffold(
        EzScreen(EzSettingsHub(
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
                appName: appName,
                androidPackage: androidPackage,
                resetTitle: () => EzConfig.l10n.ssResetAppearance,
                inDistress: const <String>{},
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
              build: (EzSubSetting subSec) => EzColorSettings(
                target: subSec,
                onUpdate: doNothing,
                appName: appName,
                androidPackage: androidPackage,
              ),
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
                onUpdate: doNothing,
                appName: appName,
                androidPackage: androidPackage,
                includeBackgroundImage: false,
                prependButton: <Widget>[
                  // Tile settings
                  const AppTileSetting(folder: false, onComplete: doNothing),
                  EzConfig.spacer,
                  const AppTileSetting(folder: true, onComplete: doNothing),

                  // TODO: fix background on always underline -> should consume not be always on
                  EzConfig.separator,
                ],
                prependPage: <Widget>[
                  // Page alignment
                  EzElevatedIconButton(
                    onPressed: () async {
                      final ListAlignment hBackup = hAlign;
                      final ListAlignment vBackup = vAlign;

                      await ezModal(
                        context: context,
                        builder: (_) => EzScrollView(
                          children: <Widget>[
                            const AlignmentSelectors(),
                            EzConfig.separator,
                          ],
                        ),
                      );

                      if (hBackup !=
                              ListAlignmentConfig.lookup(EzConfig.get(
                                  EzConfig.isDark
                                      ? darkHorizontalAlignKey
                                      : lightHorizontalAlignKey)) ||
                          vBackup !=
                              ListAlignmentConfig.lookup(EzConfig.get(
                                  EzConfig.isDark
                                      ? darkVerticalAlignKey
                                      : lightVerticalAlignKey))) {
                        await EzConfig.redrawUI(doNothing);
                      }
                    },
                    label: 'Alignment',
                    icon: const Icon(Icons.grid_3x3),
                  ),
                  EzConfig.spacer,
                ],
                appendPage: <Widget>[
                  EzConfig.spacer,

                  // Custom wallpaper
                  if (!useOSWall) ...<Widget>[
                    EzScrollView(
                      scrollDirection: Axis.horizontal,
                      startCentered: true,
                      child: EzConfig.isDark
                          ? const EzImageSetting(
                              doNothing,
                              configKey: darkBackgroundImageKey,
                              allowSolidColor: true,
                              label: 'Wallpaper',
                            )
                          : const EzImageSetting(
                              doNothing,
                              configKey: lightBackgroundImageKey,
                              allowSolidColor: true,
                              label: 'Wallpaper',
                            ),
                    ),
                    EzConfig.spacer,
                  ],

                  // Use OS switch TODO: smush this switch into a custom clear it/reset it/etc
                  EzSwitchPair(
                    text: 'Use System Wallpaper',
                    valueKey: EzConfig.isDark ? darkUseOSKey : lightUseOSKey,
                    afterChanged: (bool? choice) async {
                      if (choice == null) return;
                      await EzConfig.rebuildUI(doNothing);
                    },
                  ),
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
              build: (EzSubSetting subSec) => EzTextSettings(
                target: subSec,
                onUpdate: doNothing,
                appName: appName,
                androidPackage: androidPackage,
              ),
            ),
          ],
          target: targetPass,
        )),
        fabs: <Widget>[
          // Rebuild (conditional)
          if (config.needsRebuild) ...<Widget>[
            config.layout.spacer,
            const EzRebuildFAB(doNothing),
          ],

          // Save/upload config
          config.layout.spacer,
          EzConfigFAB(
            context,
            appName: appName,
            androidPackage: androidPackage,
          ),
        ],
      ),
    );
  }
}
