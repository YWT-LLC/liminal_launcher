/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
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

  final double margin = EzConfig.get(marginKey);
  final double spacing = EzConfig.get(spacingKey);

  // Define the build data //

  late final AppInfoProvider listener = Provider.of<AppInfoProvider>(context);

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      EzScrollView(children: <Widget>[
        if (spacing > margin) EzSpacer(space: spacing - margin),

        // Swipe selectors
        SwipeSelector(left: true, listener: listener),
        ezSpacer,
        SwipeSelector(left: false, listener: listener),
        ezSeparator,

        // Auth to edit
        const EzSwitchPair(
          text: 'Auth to edit',
          valueKey: authToEditKey,
        ),
        ezSpacer,

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
        ezSeparator,
      ]),
      fabs: settingsFABs(context),
    );
  }
}
