/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

EzMenuButton reposition(
  EzCP config,
  AppInfoProvider appInfo,
  LimPos pos, {
  required BuildContext context,
}) =>
    EzMenuButton(
      config,
      label: 'Reposition', // TODO: l10n
      icon: EzIcon(config, Icons.control_camera),
      onPressed: () async {
        marked.value = pos;
        await editSpacing(config, appInfo: appInfo, context: context);
      },
    );

EzMenuButton moveDownLane(
  EzCP config,
  AppInfoProvider appInfo,
  LimPos pos, {
  required int numLanes,
}) =>
    EzMenuButton(
      config,
      enabled: pos.lane != 0,
      label: l10n(config).mcMove,
      icon: EzIcon(
        config,
        standardFlow(config) ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right,
      ),
      onPressed: () => appInfo.moveItemDownLane(config, lane: pos.lane, index: pos.index),
    );

EzMenuButton moveUpLane(
  EzCP config,
  AppInfoProvider appInfo,
  LimPos pos, {
  required int numLanes,
}) =>
    EzMenuButton(
      config,
      enabled: pos.lane < (numLanes - 1),
      label: l10n(config).mcMove,
      icon: EzIcon(
        config,
        standardFlow(config) ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_left,
      ),
      onPressed: () => appInfo.moveItemUpLane(config, lane: pos.lane, index: pos.index),
    );

EzMenuButton removeItem(
  EzCP config,
  AppInfoProvider appInfo,
  LimPos pos,
) =>
    EzMenuButton(
      config,
      label: l10n(config).mcRemove,
      icon: EzIcon(config, Icons.remove),
      onPressed: () => appInfo.removeItem(config, lane: pos.lane, index: pos.index),
    );
