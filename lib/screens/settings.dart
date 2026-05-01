/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
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
                  additionalSettings: <Widget>[
                    EzConfig.spacer,
                    _AppListSettings(),
                  ],
                  quickConfigSpacer: EzConfig.divider,
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
                    const _HeaderSettings(),
                    EzConfig.spacer,

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

class _HeaderSettings extends StatelessWidget {
  const _HeaderSettings();

  @override
  Widget build(BuildContext context) => EzElevatedIconButton(
        label: 'Home header',
        icon: const Icon(LineIcons.clock),
        onPressed: () async {
          final String timeKey = EzConfig.isDark ? darkHomeTimeKey : lightHomeTimeKey;
          final bool backupTime = EzConfig.get(timeKey);

          final String dateKey = EzConfig.isDark ? darkHomeDateKey : lightHomeDateKey;
          final DateType backupDate = DateTypeConfig.lookup(EzConfig.get(dateKey));

          await ezModal(
            context: context,
            builder: (BuildContext mCon) => EzScrollView(
              children: <Widget>[
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
                EzConfig.spacer,

                // Home Time
                EzSwitchPair(
                  text: 'Show time',
                  valueKey: timeKey,
                  afterChanged: (bool? choice) async {
                    if (choice == null) return;
                    if (EzConfig.updateBoth) {
                      await EzConfig.setBool(
                        EzConfig.isDark ? lightHomeTimeKey : darkHomeTimeKey,
                        choice,
                      );
                    }
                  },
                ),
                EzConfig.spacer,

                // Home Date
                EzScrollView(
                  scrollDirection: Axis.horizontal,
                  reverseHands: true,
                  children: <Widget>[
                    // Label
                    EzText(
                      'Date type',
                      style: EzConfig.styles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    EzConfig.margin,

                    // Button
                    EzDropdownMenu<DateType>(
                      enableSearch: false,
                      initialSelection: homeDate,
                      dropdownMenuEntries: DateType.values
                          .map((DateType type) => DropdownMenuEntry<DateType>(
                              value: type,
                              label: DateTypeConfig.buildDate(
                                mCon,
                                DateTime.now(),
                                type,
                              )))
                          .toList(),
                      widthEntry: 'Wednesday, Sept',
                      onSelected: (DateType? choice) async {
                        if (choice == null) return;

                        if (EzConfig.updateBoth || EzConfig.isDark) {
                          await EzConfig.setString(darkHomeDateKey, choice.value);
                        }
                        if (EzConfig.updateBoth || !EzConfig.isDark) {
                          await EzConfig.setString(lightHomeDateKey, choice.value);
                        }
                      },
                    ),
                  ],
                ),
                EzConfig.separator,
              ],
            ),
          );

          if (backupTime != EzConfig.get(timeKey) ||
              backupDate != DateTypeConfig.lookup(EzConfig.get(dateKey))) {
            await EzConfig.rebuildUI();
          }
        },
      );
}

class _AppListSettings extends StatelessWidget {
  _AppListSettings();

  // Define build data //

  late final TextEditingController timeoutText = TextEditingController();
  late final ScrollController timeoutScroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    final Size sizeLimit = ezTextSize(
      '55',
      context: context,
      style: EzConfig.styles.bodyLarge,
    );

    final double formFieldHeight =
        max(sizeLimit.height + EzConfig.padding, kMinInteractiveDimension);
    final double formFieldWidth = max(sizeLimit.width + EzConfig.padding, kMinInteractiveDimension);

    // Return the build //

    return EzElevatedIconButton(
      label: 'App list',
      icon: const Icon(Icons.list),
      onPressed: () async {
        final int timeoutBackup = int.tryParse(await EzConfig.secGet(authTimeoutKey)) ??
            (limSecDef[authTimeoutKey] as int);
        timeoutText.text = timeoutBackup.toString();

        final String wideKey = EzConfig.isDark ? darkWideTilesKey : lightWideTilesKey;
        final bool wideBackup = wideTiles;

        if (context.mounted) {
          await ezModal(
            context: context,
            builder: (_) => EzScrollView(
              controller: timeoutScroll,
              children: <Widget>[
                // Swipe selectors
                Text(
                  'Swipe left/right on the home screen (not in editing mode) to open the selected app.\n\nLong press to clear your selection.',
                  textAlign: TextAlign.center,
                  style: EzConfig.styles.bodyLarge,
                ),
                EzConfig.spacer,
                const SwipeSelector(left: true),
                EzConfig.spacer,
                const SwipeSelector(left: false),
                EzConfig.divider,

                // Auto add to home
                const EzSwitchPair(
                  text: 'Auto-add new apps to home',
                  valueKey: autoAddToHomeKey,
                ),
                EzConfig.spacer,

                // Auto search
                const EzSwitchPair(
                  text: 'Auto-search the apps list',
                  valueKey: autoSearchKey,
                ),
                EzConfig.separator,

                // Auth to edit
                const EzSwitchPair(
                  text: 'Auth to edit lists/settings',
                  valueKey: authToEditKey,
                  secureKey: true,
                ),
                EzConfig.spacer,

                // Auth for hidden
                const EzSwitchPair(
                  text: 'Auth to see hidden apps',
                  valueKey: authForHiddenKey,
                  secureKey: true,
                ),
                EzConfig.spacer,

                // Re-auth timer
                EzRow(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Label
                    Flexible(
                      child: Text(
                        'Auth timeout (mins)',
                        textAlign: TextAlign.start,
                        style: EzConfig.styles.bodyLarge,
                      ),
                    ),
                    EzConfig.rowSpacer,

                    // Field
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: formFieldHeight,
                        maxWidth: formFieldWidth,
                      ),
                      child: TextFormField(
                        controller: timeoutText,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.top,
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        onTap: () async {
                          // Wait a half sec for the Spacer to resize first
                          await Future<void>.delayed(const Duration(milliseconds: 500));

                          // Scroll to the bottom
                          await timeoutScroll.animateTo(
                            timeoutScroll.position.maxScrollExtent,
                            duration: ezAnimDuration(),
                            curve: Curves.easeInOut,
                          );
                        },
                        validator: (String? value) {
                          if (value == null) return null;
                          final int? intVal = int.tryParse(value);

                          if (intVal == null || intVal < 0) {
                            return 'Positive integers only';
                          }
                          return null;
                        },
                        onFieldSubmitted: (String stringVal) async {
                          final int? intVal = int.tryParse(stringVal);

                          if (intVal == null || intVal < 0) {
                            return;
                          }
                          await EzConfig.secSet(authTimeoutKey, intVal.toString());
                        },
                      ),
                    ),
                  ],
                ),
                EzSpacer(space: MediaQuery.of(context).viewInsets.bottom),
                EzConfig.separator,
              ],
            ),
          );
        }

        if (wideBackup != EzConfig.get(wideKey)) await EzConfig.rebuildUI();
      },
    );
  }
}
