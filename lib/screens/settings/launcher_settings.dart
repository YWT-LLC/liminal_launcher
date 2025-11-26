/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';

class LauncherSettingsScreen extends StatefulWidget {
  const LauncherSettingsScreen({super.key});

  @override
  State<LauncherSettingsScreen> createState() => _LauncherSettingsScreenState();
}

class _LauncherSettingsScreenState extends State<LauncherSettingsScreen> {
  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      const SizedBox.shrink(),
      fabs: settingsFABs(context),
    );
  }
}
