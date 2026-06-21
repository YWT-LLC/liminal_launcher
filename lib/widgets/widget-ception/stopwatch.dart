/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: states, ripples, and edits

class StopwatchWidget extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;

  const StopwatchWidget(
    this.config,
    this.appInfo,
    this.lane,
    this.index,
    this.state, {
    super.key,
  });

  @override
  Widget build(BuildContext context) => EzIconButton(
        config,
        icon: EzIcon(config, Icons.watch),
        onPressed: openStopwatch,
      );
}
