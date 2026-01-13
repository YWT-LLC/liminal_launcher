/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

/// Lots of custom animations in Liminal, having a global final makes things easier
final Duration animDuration = ezAnimDuration();

/// Tracks the position of the last ripple LongPress
/// Defaults to [Offset.zero]
Offset lastRipple = Offset.zero;

/// [FloatingActionButton] list for the settings screens
List<Widget> settingsFABs(BuildContext context, {bool home = false}) =>
    <Widget>[
      EzConfig.layout.spacer,
      EzConfigFAB(
        context,
        appName: appName,
        androidPackage: androidPackage,
        extraKeys: extraSaveKeys,
      ),
      EzConfig.layout.spacer,
      EzBackFAB(showHome: home),
    ];
