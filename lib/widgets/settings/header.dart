/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class HeaderSettings extends StatelessWidget {
  final EzCP config;

  const HeaderSettings(this.config, {super.key});

  @override
  Widget build(BuildContext context) => EzElevatedIconButton(
        config,
        label: 'Home header',
        icon: EzIcon(config, LineIcons.clock),
        onPressed: () async {
          final String timeKey = config.isDark ? darkHomeTimeKey : lightHomeTimeKey;
          final bool backupTime = EzCM.get(timeKey);

          final String dateKey = config.isDark ? darkHomeDateKey : lightHomeDateKey;
          final DateType backupDate = DTConfig.lookup(EzCM.get(dateKey));

          await ezModal(
            config,
            context: context,
            builder: (BuildContext mCon) => ezModalScroll(config, children: <Widget>[
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

              // Home Time
              EzSwitchPair(
                config,
                text: 'Show time',
                valueKey: timeKey,
                afterChanged: (bool? choice) async {
                  if (choice == null) return;
                  if (EzCM.updateBoth) {
                    await EzCM.setBool(
                      config.isDark ? lightHomeTimeKey : darkHomeTimeKey,
                      choice,
                    );
                  }
                },
              ),
              config.spacer,

              // Home Date
              EzScrollView(
                config,
                scrollDirection: Axis.horizontal,
                reverseHands: true,
                children: <Widget>[
                  // Label
                  EzText(
                    config,
                    text: 'Date type',
                    style: config.bodyStyle,
                    textAlign: TextAlign.center,
                  ),
                  config.margin,

                  // Button
                  EzDropdownMenu<DateType>(
                    config,
                    enableSearch: false,
                    initialSelection: homeDate(config),
                    dropdownMenuEntries: DateType.values
                        .map((DateType type) => DropdownMenuEntry<DateType>(
                            value: type,
                            label: DTConfig.buildDate(
                              mCon,
                              DateTime.now(),
                              type,
                            )))
                        .toList(),
                    widthEntry: 'Wednesday, Sept',
                    onSelected: (DateType? choice) async {
                      if (choice == null) return;

                      if (EzCM.updateBoth || config.isDark) {
                        await EzCM.setString(darkHomeDateKey, choice.value);
                      }
                      if (EzCM.updateBoth || !config.isDark) {
                        await EzCM.setString(lightHomeDateKey, choice.value);
                      }
                    },
                  ),
                ],
              ),
              config.separator,
            ]),
          );

          if (backupTime != EzCM.get(timeKey) || backupDate != DTConfig.lookup(EzCM.get(dateKey))) {
            await config.rebuildUI(<EzCacheType>{EzCacheType.design});
          }
        },
      );
}
