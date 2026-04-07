/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  // Define the build data //

  late final AppInfoProvider appProvider =
      Provider.of<AppInfoProvider>(context);

  bool resetAll = false;

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

  //* Return the build *//

  @override
  Widget build(BuildContext context) {
    const EzSpacer ezSpacer = EzSpacer();

    return LiminalScaffold(
      EzScrollView(
        children: <Widget>[
          // TODO: Need a new home for showTips

          // Launcher
          EzElevatedIconButton(
            onPressed: () => context.goNamed(launcherSettingsPath),
            icon: const Icon(Icons.navigate_next),
            label: 'Launcher settings',
          ),
          ezSpacer,

          // Batch //
          const EzQuickConfig(),
          ezSpacer,

          // Randomize

          ezSpacer,

          // Reset
          EzElevatedIconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => StatefulBuilder(
                builder: (BuildContext dContext, StateSetter dialogState) =>
                    EzAlertDialog(
                  key: ValueKey<bool>(resetAll),
                  title: const Text(
                    'Reset all appearance settings?',
                    textAlign: TextAlign.center,
                  ),
                  content: SizedBox(
                    width: widthOf(context),
                    child: EzScrollView(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        EzSwitchPair(
                          text: 'Or, ALL settings',
                          value: resetAll,
                          onChanged: (bool? choice) {
                            resetAll = (choice == null) ? false : choice;
                            setState(() {});
                            dialogState(() {});
                          },
                        ),
                        ezSpacer,
                        ezRichUndoWarning(
                          context,
                          standalone: false,
                          appName: appName,
                          androidPackage: androidPackage,
                        ),
                      ],
                    ),
                  ),
                  actions: ezActionPair(
                    context: context,
                    onConfirm: () async {
                      await EzConfig.reset(
                        skip: resetAll ? neverResetKeys : defaultNoResetKeys,
                      );
                      if (resetAll) await appProvider.reset();
                      if (dContext.mounted) Navigator.of(dContext).pop();
                    },
                    confirmIsDestructive: true,
                    onDeny: () => Navigator.of(dContext).pop(),
                  ),
                  needsClose: false,
                ),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: EzConfig.l10n.gResetAll,
          ),
          EzConfig.separator,
        ],
      ),
      fabs: settingsFABs(context, home: true),
    );
  }
}
