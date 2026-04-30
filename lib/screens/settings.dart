/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                  includeBackgroundImage: false,
                  prependPage: <Widget>[
                    // Wallpaper
                    EzImageSetting(
                      configKey: EzConfig.isDark ? darkBackgroundImageKey : lightBackgroundImageKey,
                      label: 'Wallpaper',
                      allowSolidColor: true,
                      clearLabel: 'Use OS',
                      defaultFit: BoxFit.cover,
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
                            children: <Widget>[
                              const AlignmentSelectors(),
                              EzConfig.separator,
                            ],
                          ),
                        );

                        if (hBackup !=
                                LAConfig.lookup(EzConfig.get(EzConfig.isDark
                                    ? darkHorizontalAlignKey
                                    : lightHorizontalAlignKey)) ||
                            vBackup !=
                                LAConfig.lookup(EzConfig.get(EzConfig.isDark
                                    ? darkVerticalAlignKey
                                    : lightVerticalAlignKey))) {
                          await EzConfig.redrawUI();
                        }
                      },
                      label: 'Alignment',
                      icon: const Icon(Icons.grid_3x3),
                    ),
                    EzConfig.spacer,
                  ],
                  appendPage: <Widget>[
                    EzConfig.spacer,
                    // Hide status bar
                    EzSwitchPair(
                      text: 'Hide status bar',
                      valueKey: EzConfig.isDark ? darkHideStatusKey : lightHideStatusKey,
                      afterChanged: (bool? choice) async {
                        if (choice == null) return;
                        if (EzConfig.updateBoth) {
                          await EzConfig.setBool(
                            EzConfig.isDark ? lightHideStatusKey : darkHideStatusKey,
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
