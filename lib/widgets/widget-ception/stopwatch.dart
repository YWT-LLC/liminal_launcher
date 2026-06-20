/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class StopwatchWidget extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;

  late final WidgetSize _size;
  late final List<String>? _extra;
  late final Future<void> Function(String, bool) _save;

  StopwatchWidget(this.config, this.appInfo, this.lane, this.index, this.state, {super.key}) {
    final List<String> data = appInfo.homeList(config, lane)[index].split(widgetSplit);

    final WidgetSize size = WSConfig.lookup(data[1]);
    _size = (size == WidgetSize.system) ? bt2WS(config) : size;

    _extra = data.length > 2 ? data.sublist(2) : null;

    _save = (_, __) async {};
  }

  @override
  Widget build(BuildContext context) => switch (_size) {
        WidgetSize.system => const SizedBox.shrink(), // override above
        WidgetSize.button || _ => EzIconButton(
            config,
            icon: EzIcon(config, Icons.watch),
            onPressed: openStopwatch,
          ),
      };
}
