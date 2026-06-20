/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: states, ripples, and edits

class ToggleMediaWidget extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;

  late final WidgetSize _size;

  ToggleMediaWidget(this.config, this.appInfo, this.lane, this.index, this.state, {super.key}) {
    final List<String> data = appInfo.homeList(config, lane)[index].split(widgetSplit);

    final WidgetSize size = WSConfig.lookup(data[1]);
    _size = (size == WidgetSize.system) ? bt2WS(config) : size;
  }

  @override
  Widget build(BuildContext context) => switch (_size) {
        WidgetSize.button => EzIconButton(
            config,
            icon: EzIcon(config, Icons.headphones),
            onPressed: toggleMedia,
          ),
        _ => EzIconButton(
            config,
            icon: EzRow(config, children: <Widget>[
              // Previous
              config.rowMargin,
              GestureDetector(
                onTap: skipPrev,
                child: Icon(Icons.skip_previous, size: appIconSize(config)),
              ),
              config.rowSpacer,

              // Play/pause
              GestureDetector(
                onTap: toggleMedia,
                child: Icon(Icons.headphones, size: appIconSize(config)),
              ),
              config.rowSpacer,

              // Next
              GestureDetector(
                onTap: skipNext,
                child: Icon(Icons.skip_next, size: appIconSize(config)),
              ),
              config.rowMargin,
            ]),
            onPressed: doNothing,
            onLongPress: doNothing,
          ),
      };
}
