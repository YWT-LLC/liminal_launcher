/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:after_layout/after_layout.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class SettingsHomeScreen extends StatefulWidget {
  SettingsHomeScreen() : super(key: ValueKey<int>(EzConfig.seed));

  @override
  State<SettingsHomeScreen> createState() => _SettingsHomeScreenState();
}

class _SettingsHomeScreenState extends State<SettingsHomeScreen>
    with AfterLayoutMixin<SettingsHomeScreen> {
  // Define custom functions //

  Future<dynamic> showTips() => showDialog(
        context: context,
        builder: (_) => const EzAlertDialog(
          title: Text('Tips', textAlign: TextAlign.center),
          content: Text('&& tricks', textAlign: TextAlign.center),
        ),
      );

  // Init //

  @override
  void afterFirstLayout(BuildContext context) async {
    if (!(await isGPlayInstall()) &&
        !EzConfig.get(shownReminderKey) &&
        context.mounted) {
      await showDialog(
        context: context,
        builder: (_) => EzAlertDialog(
          title: const Text(
            'Welcome to Liminal Launcher',
            textAlign: TextAlign.center,
          ),
          content: EzRichText(
            <InlineSpan>[
              const EzPlainText(
                text:
                    '''We hope it serves you well! This version is not from the Play Store, so it should have been free.
Rest assured, the free version of Liminal will always be identical to the Google Play version.

With that said, if you want to support Liminal's development, or the development of more Empathetech software, please consider ''',
              ),
              EzInlineLink(
                'contributing',
                style: EzConfig.styles.bodyLarge,
                textAlign: TextAlign.center,
                url: Uri.parse('https://www.empathetech.net/#/contribute'),
                hint: 'Open a link to the Empathetic contribution options.',
              ),
              const EzPlainText(
                text: '''.

This is the only non-tutorial dialog that will appear.
And it will not appear again.

Thank you, and enjoy!''',
              ),
            ],
            style: EzConfig.styles.bodyLarge,
            textBackground: false,
            textAlign: TextAlign.center,
          ),
        ),
      );
      await EzConfig.setBool(shownReminderKey, true);
    }
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      EzScrollView(children: <Widget>[
        // TODO: Need a new home for showTips
        EzHeader(),

        // Swipe selectors
        const SwipeSelector(left: true),
        EzConfig.spacer,
        const SwipeSelector(left: false),
        EzConfig.separator,

        // Hide status bar
        const EzSwitchPair(text: 'Hide status bar', valueKey: hideStatusKey),
        EzConfig.spacer,

        // Auto add to home
        const EzSwitchPair(
            text: 'Add new apps to home', valueKey: autoAddToHomeKey),
        EzConfig.spacer,

        // Auto search
        const EzSwitchPair(text: 'Auto search', valueKey: autoSearchKey),
        EzConfig.spacer,

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
