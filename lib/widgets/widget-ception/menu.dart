/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

EzMenuButton moveDownLane(
  EzCP config,
  AppInfoProvider appInfo, {
  required int numLanes,
  required int lane,
  required int index,
}) =>
    EzMenuButton(
      config,
      enabled: lane != 0,
      label: 'Move',
      icon: EzIcon(
        config,
        hAlign(config) == ListAlignment.end
            ? Icons.keyboard_arrow_left
            : Icons.keyboard_arrow_right,
      ),
      onPressed: () => appInfo.moveItemDownLane(config, lane: lane, index: index),
    );

EzMenuButton moveUpLane(
  EzCP config,
  AppInfoProvider appInfo, {
  required int numLanes,
  required int lane,
  required int index,
}) =>
    EzMenuButton(
      config,
      enabled: lane < (numLanes - 1),
      label: 'Move',
      icon: EzIcon(
        config,
        hAlign(config) == ListAlignment.end
            ? Icons.keyboard_arrow_right
            : Icons.keyboard_arrow_left,
      ),
      onPressed: () => appInfo.moveItemUpLane(config, lane: lane, index: index),
    );
