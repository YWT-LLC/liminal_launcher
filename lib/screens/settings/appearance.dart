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
  /// [EzSettingsHub.target] passthrough
  final int? target;

  /// [EzColorSettings.advanced] and/or [EzTextSettings.advanced] passthrough
  final bool? advanced;

  AppearanceSettingsScreen({this.target, this.advanced})
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
              build: EzGlobalSettings(
                appName: appName,
                androidPackage: androidPackage,
                resetTitle: () => 'Reset all appearance settings?',
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
              build: EzColorSettings(
                advanced: advanced,
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
              build: EzDesignSettings(
                pageTab: advanced,
                onUpdate: doNothing,
                includeBackgroundImage: false,
                appendButton: <Widget>[
                  EzConfig.spacer,

                  // Tile settings
                  const AppTileSetting(folder: false, onComplete: doNothing),
                  EzConfig.spacer,
                  const AppTileSetting(folder: true, onComplete: doNothing),
                ],
                appendPage: <Widget>[
                  EzConfig.spacer,

                  // Custom wallpaper
                  if (!useOSWall) ...<Widget>[
                    EzScrollView(
                      scrollDirection: Axis.horizontal,
                      startCentered: true,
                      mainAxisSize: MainAxisSize.min,
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

                  // Use OS switch
                  EzSwitchPair(
                    text: 'Use System Wallpaper',
                    valueKey: EzConfig.isDark ? darkUseOSKey : lightUseOSKey,
                    afterChanged: (bool? choice) async {
                      if (choice == null) return;
                      await EzConfig.rebuildUI(doNothing);
                    },
                  ),
                  EzConfig.separator,

                  // Page alignment
                  EzElevatedIconButton(
                    onPressed: () async {
                      final ListAlignment hBackup = hAlign;
                      final ListAlignment vBackup = vAlign;

                      await ezModal(
                        context: context,
                        builder: (_) => EzScrollView(
                          mainAxisSize: MainAxisSize.min,
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
                    label: 'Page alignment',
                    icon: const Icon(Icons.home),
                  ),
                  EzConfig.spacer,
                ],
                resetSpacerPage: EzConfig.divider,
                appName: appName,
                androidPackage: androidPackage,
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
              build: EzTextSettings(
                advanced: advanced,
                onUpdate: doNothing,
                appName: appName,
                androidPackage: androidPackage,
              ),
            ),
          ],
          target: target,
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
