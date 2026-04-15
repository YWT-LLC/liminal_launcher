/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class SettingsHomeScreen extends StatelessWidget {
  SettingsHomeScreen() : super(key: ValueKey<int>(EzConfig.seed));

  @override
  Widget build(BuildContext context) => LiminalScaffold(
        Center(
          child: EzScrollView(children: <Widget>[
            const _HeaderSettings(), // TODO: local resets (no reset all)
            EzConfig.spacer,
            const _SwipeSettings(),
            EzConfig.spacer,
            _AppListSettings(),
            EzConfig.spacer,
            const EzThemeCoin(),
            EzConfig.divider,
            EzElevatedIconButton(
              onPressed: () => context.goNamed(appearanceSettingsPath),
              icon: const Icon(Icons.navigate_next),
              label: 'Appearance settings',
            ),
          ]),
        ),
        fabs: settingsFABs(context, home: true),
      );
}

class _HeaderSettings extends StatelessWidget {
  const _HeaderSettings();

  @override
  Widget build(BuildContext context) {
    return EzElevatedIconButton(
      label: 'Home header',
      icon: const Icon(LineIcons.clock),
      onPressed: () async {
        final String statusKey =
            EzConfig.isDark ? darkHideStatusKey : lightHideStatusKey;
        final bool backupStatus = EzConfig.get(statusKey);

        final String timeKey =
            EzConfig.isDark ? darkHomeTimeKey : lightHomeTimeKey;
        final bool backupTime = EzConfig.get(timeKey);

        final String dateKey =
            EzConfig.isDark ? darkHomeDateKey : lightHomeDateKey;
        final DateType backupDate =
            DateTypeConfig.lookup(EzConfig.get(dateKey));

        await ezModal(
          context: context,
          builder: (BuildContext mContext) => EzScrollView(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Hide status bar
              EzSwitchPair(
                text: 'Hide status bar',
                valueKey: statusKey,
                afterChanged: (bool? choice) async {
                  if (choice == null) return;
                  if (EzConfig.updateBoth) {
                    await EzConfig.setBool(
                      EzConfig.isDark ? lightHideStatusKey : darkHideStatusKey,
                      choice,
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
                mainAxisSize: MainAxisSize.min,
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
                              mContext,
                              DateTime.now(),
                              type,
                            )))
                        .toList(),
                    widthEntries: <String>['Wednesday, Sept'],
                    onSelected: (DateType? choice) async {
                      if (choice == null) return;

                      if (EzConfig.updateBoth || EzConfig.isDark) {
                        await EzConfig.setString(darkHomeDateKey, choice.value);
                      }
                      if (EzConfig.updateBoth || !EzConfig.isDark) {
                        await EzConfig.setString(
                            lightHomeDateKey, choice.value);
                      }
                    },
                  ),
                ],
              ),
              EzConfig.separator,
            ],
          ),
        );

        if (backupStatus != EzConfig.get(statusKey) ||
            backupTime != EzConfig.get(timeKey) ||
            backupDate != DateTypeConfig.lookup(EzConfig.get(dateKey))) {
          await EzConfig.rebuildUI(doNothing);
        }
      },
    );
  }
}

class _SwipeSettings extends StatelessWidget {
  const _SwipeSettings();

  @override
  Widget build(BuildContext context) => EzElevatedIconButton(
        label: 'Quick launch',
        icon: const Icon(Icons.swipe),
        onPressed: () => ezModal(
          context: context,
          builder: (_) => EzScrollView(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Swipe left/right on the home screen (not in editing mode) to open the selected app.\n\nLong press to clear your selection.',
                textAlign: TextAlign.center,
                style: EzConfig.styles.bodyLarge,
              ),
              EzConfig.separator,
              const SwipeSelector(left: true),
              EzConfig.spacer,
              const SwipeSelector(left: false),
              EzConfig.separator,
            ],
          ),
        ),
      );
}

class _AppListSettings extends StatelessWidget {
  _AppListSettings();

  late final TextEditingController timeoutText =
      TextEditingController(text: EzConfig.get(authTimeoutKey).toString());
  late final ScrollController timeoutScroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    return EzElevatedIconButton(
      label: 'App list',
      icon: const Icon(Icons.list),
      onPressed: () async {
        final String wideKey =
            EzConfig.isDark ? darkWideTilesKey : lightWideTilesKey;
        final bool wideBackup = wideTiles;

        final int timeoutBackup = EzConfig.get(authTimeoutKey);
        late final Size sizeLimit = ezTextSize(
          '55',
          context: context,
          style: EzConfig.styles.bodyLarge,
        );

        late final double formFieldHeight =
            max(sizeLimit.height + EzConfig.padding, kMinInteractiveDimension);
        late final double formFieldWidth =
            max(sizeLimit.width + EzConfig.padding, kMinInteractiveDimension);

        await ezModal(
          context: context,
          builder: (_) => EzScrollView(
            controller: timeoutScroll,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Theme dependent',
                textAlign: TextAlign.center,
                style: EzConfig.styles.labelLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              EzConfig.spacer,

              // Wide tiles
              EzSwitchPair(
                text: 'Max width app tiles',
                valueKey: wideKey,
                afterChanged: (bool? choice) async {
                  if (choice == null) return;
                  if (EzConfig.updateBoth) {
                    await EzConfig.setBool(
                      EzConfig.isDark ? lightWideTilesKey : darkWideTilesKey,
                      choice,
                    );
                  }
                },
              ),

              EzDivider(
                constraints: const BoxConstraints(maxWidth: double.infinity),
                title: Text(
                  'Constant',
                  textAlign: TextAlign.center,
                  style: EzConfig.styles.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

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
              ),
              EzConfig.spacer,

              // Auth for hidden
              const EzSwitchPair(
                text: 'Auth to see hidden apps',
                valueKey: authForHiddenKey,
              ),
              EzConfig.separator,

              // Re-auth timer
              EzRow(
                mainAxisSize: MainAxisSize.min,
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
                        await Future<void>.delayed(
                            const Duration(milliseconds: 500));

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
                        await EzConfig.setInt(authTimeoutKey, intVal);
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

        if (wideBackup != EzConfig.get(wideKey) ||
            timeoutBackup != EzConfig.get(authTimeoutKey)) {
          await EzConfig.redrawUI(doNothing);
        }
      },
    );
  }
}
