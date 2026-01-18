/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class LauncherSettingsScreen extends StatefulWidget {
  const LauncherSettingsScreen({super.key});

  @override
  State<LauncherSettingsScreen> createState() => _LauncherSettingsScreenState();
}

class _LauncherSettingsScreenState extends State<LauncherSettingsScreen> {
  // Gather the fixed theme data //

  // Define the build data //

  late final AppInfoProvider appProvider =
      Provider.of<AppInfoProvider>(context);

  // Return the build //

  @override
  Widget build(BuildContext context) {
    const EzSpacer ezSpacer = EzSpacer();

    return LiminalScaffold(
      EzScrollView(children: <Widget>[
        EzHeader(),

        // Swipe selectors
        SwipeSelector(left: true, appProvider: appProvider),
        ezSpacer,
        SwipeSelector(left: false, appProvider: appProvider),
        EzConfig.divider,

        // Hide status bar
        const EzSwitchPair(
          text: 'Hide status bar',
          valueKey: hideStatusKey,
        ),
        ezSpacer,

        // Auto add to home
        const EzSwitchPair(
          text: 'Add new apps to home',
          valueKey: autoAddToHomeKey,
        ),
        ezSpacer,

        // Auto search
        const EzSwitchPair(
          text: 'Auto search',
          valueKey: autoSearchKey,
        ),
        ezSpacer,

        // Auth to edit
        const EzSwitchPair(
          text: 'Auth to edit',
          valueKey: authToEditKey,
        ),
        ezSpacer,

        // Auth for hidden
        const EzSwitchPair(
          text: 'Auth for hidden',
          valueKey: authForHiddenKey,
        ),
        EzConfig.separator,
      ]),
      fabs: settingsFABs(context),
    );
  }
}
