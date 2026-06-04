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
  const HeaderSettings({super.key});

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
            builder: (BuildContext mCon) => ezModalScroll(<Widget>[
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
                    style: EzConfig.bodyStyle,
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
            ]),
          );

          if (backupTime != EzConfig.get(timeKey) ||
              backupDate != DateTypeConfig.lookup(EzConfig.get(dateKey))) {
            await EzConfig.rebuildUI();
          }
        },
      );
}
