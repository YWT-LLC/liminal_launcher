/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../../widgets/export.dart';

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
            const _HeaderSettings(),
            EzConfig.spacer,
            const _SwipeSettings(),
            EzConfig.spacer,
            const _AppListSettings(),
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
      onPressed: () => ezModal(
        context: context,
        builder: (BuildContext modalContext) => EzScrollView(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Hide status bar
            EzSwitchPair(
              // TODO: either make work, or add snack to tell them to restart
              text: 'Hide status bar',
              valueKey: hideStatusKey,
              afterChanged: (_) => EzConfig.rebuildUI(doNothing),
            ),
            EzConfig.spacer,

            // Home Time
            EzSwitchPair(
              text: 'Show time',
              valueKey: EzConfig.isDark ? darkHomeTimeKey : lightHomeTimeKey,
            ),
            EzConfig.spacer,

            // Home Date
            // TODO: add checks on close for redrawUI (rebuild shouldn't be needed)
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
                            modalContext,
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
                      await EzConfig.setString(lightHomeDateKey, choice.value);
                    }
                  },
                ),
              ],
            ),
            EzConfig.separator,
          ],
        ),
      ),
    );
  }
}

class _SwipeSettings extends StatelessWidget {
  // TODO: dark/light split
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
                'Swipe left/right on the home screen (not in editing mode) to open the selected app.',
                textAlign: TextAlign.center,
                style: EzConfig.styles.bodyLarge,
              ),
              EzConfig.spacer,
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
  const _AppListSettings();

  @override
  Widget build(BuildContext context) => EzElevatedIconButton(
        label: 'App list',
        icon: const Icon(Icons.list),
        onPressed: () => ezModal(
          context: context,
          builder: (_) => EzScrollView(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
            ],
          ),
        ),
      );
}
