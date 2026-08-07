/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

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
      label: l10n(config).mcMove,
      icon: EzIcon(
        config,
        standardFlow(config) ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right,
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
      label: l10n(config).mcMove,
      icon: EzIcon(
        config,
        standardFlow(config) ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_left,
      ),
      onPressed: () => appInfo.moveItemUpLane(config, lane: lane, index: index),
    );

EzMenuButton removeItem(
  EzCP config,
  AppInfoProvider appInfo, {
  required int lane,
  required int index,
}) =>
    EzMenuButton(
      config,
      label: l10n(config).mcRemove,
      icon: EzIcon(config, Icons.remove),
      onPressed: () => appInfo.removeItem(config, lane: lane, index: index),
    );
