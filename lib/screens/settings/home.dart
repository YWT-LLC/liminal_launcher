/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class SettingsHomeScreen extends StatelessWidget {
  SettingsHomeScreen() : super(key: ValueKey<int>(EzConfig.seed));

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    return LiminalScaffold(
      EzScrollView(children: <Widget>[
        EzHeader(),

        // Swipe selectors
        const SwipeSelector(left: true),
        EzConfig.spacer,
        const SwipeSelector(left: false),
        EzConfig.separator,

        // Hide status bar
        EzSwitchPair(
          text: 'Hide status bar',
          valueKey: hideStatusKey,
          onChanged: (_) => EzConfig.rebuildUI(doNothing),
        ),
        EzConfig.spacer,

        // Home Time
        EzSwitchPair(
          text: 'Show time',
          valueKey: EzConfig.isDark ? darkHomeTimeKey : lightHomeTimeKey,
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
                        label: DateTypeConfig.buildDate(type, context, now),
                      ))
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

                await EzConfig.redrawUI(doNothing);
              },
            ),
          ],
        ),
        EzConfig.separator,

        // Auto add to home
        const EzSwitchPair(
          text: 'Add new apps to home',
          valueKey: autoAddToHomeKey,
        ),
        EzConfig.spacer,

        // Auto search
        const EzSwitchPair(text: 'Auto search', valueKey: autoSearchKey),
        EzConfig.separator,

        // Auth to edit
        const EzSwitchPair(text: 'Auth to edit', valueKey: authToEditKey),
        EzConfig.spacer,

        // Auth for hidden
        const EzSwitchPair(text: 'Auth for hidden', valueKey: authForHiddenKey),
        EzConfig.divider,

        // Appearance
        EzElevatedIconButton(
          onPressed: () => context.goNamed(appearanceSettingsPath),
          icon: const Icon(Icons.navigate_next),
          label: 'Appearance settings',
        ),
        EzConfig.separator,
      ]),
      fabs: settingsFABs(context, home: true),
    );
  }
}

// TODO: find me a new home
// @override
//   void afterFirstLayout(BuildContext context) async {
//     if (!(await isGPlayInstall()) &&
//         !EzConfig.get(shownReminderKey) &&
//         context.mounted) {
//       await showDialog(
//         context: context,
//         builder: (_) => EzAlertDialog(
//           title: const Text(
//             'Welcome to Liminal Launcher',
//             textAlign: TextAlign.center,
//           ),
//           content: EzRichText(
//             <InlineSpan>[
//               const EzPlainText(
//                 text:
//                     '''We hope it serves you well! This version is not from the Play Store, so it should have been free.
// Rest assured, the free version of Liminal will always be identical to the Google Play version.

// With that said, if you want to support Liminal's development, or the development of more Empathetech software, please consider ''',
//               ),
//               EzInlineLink(
//                 'contributing',
//                 style: EzConfig.styles.bodyLarge,
//                 textAlign: TextAlign.center,
//                 url: Uri.parse('https://www.empathetech.net/#/contribute'),
//                 hint: 'Open a link to the Empathetic contribution options.',
//               ),
//               const EzPlainText(
//                 text: '''.

// This is the only non-tutorial dialog that will appear.
// And it will not appear again.

// Thank you, and enjoy!''',
//               ),
//             ],
//             style: EzConfig.styles.bodyLarge,
//             textBackground: false,
//             textAlign: TextAlign.center,
//           ),
//         ),
//       );
//       await EzConfig.setBool(shownReminderKey, true);
//     }
//   }

// TODO: Find me a new home
// Future<dynamic> showTips() => showDialog(
//       context: context,
//       builder: (_) => const EzAlertDialog(
//         title: Text('Tips', textAlign: TextAlign.center),
//         content: Text('&& tricks', textAlign: TextAlign.center),
//       ),
//     );
