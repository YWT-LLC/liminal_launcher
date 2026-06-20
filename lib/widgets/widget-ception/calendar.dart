/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: states, ripples, and edits

class CalendarWidget extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;

  late final WidgetSize _size;
  late final List<String>? _extra;
  late final Future<void> Function(String, bool) _save;

  CalendarWidget(this.config, this.appInfo, this.lane, this.index, this.state, {super.key}) {
    final List<String> data = appInfo.homeList(config, lane)[index].split(widgetSplit);

    final WidgetSize size = WSConfig.lookup(data[1]);
    _size = (size == WidgetSize.system) ? bt2WS(config) : size;

    _extra = data.length > 2 ? data.sublist(2) : null;

    _save = (_, __) async {};
  }

  @override
  Widget build(BuildContext context) => switch (_size) {
        WidgetSize.button => EzIconButton(
            config,
            iconSize: appIconSize(config),
            icon: const Icon(Icons.edit_calendar),
            onPressed: () async {
              final bool success = await createCalendarEvent();

              if (!success && context.mounted) {
                await showDialog(
                  context: context,
                  builder: (_) => EzAlertDialog(
                    config,
                    title: const Text('Failed', textAlign: TextAlign.center),
                    content: const Text(
                      "There likely isn't a default calendar app.\nShall I self-destruct?",
                      textAlign: TextAlign.center,
                    ),
                    actions: <Widget>[
                      EzMaterialAction(
                        config,
                        text: 'Yes',
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await ezNoTouch(() async => await appInfo.deleteWidget(
                                config,
                                lane: lane,
                                index: index,
                              ));
                        },
                        isDestructiveAction: true,
                        isDefaultAction: true,
                      ),
                      EzMaterialAction(
                        config,
                        text: 'No',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                    needsClose: false,
                  ),
                );
              }
            },
          ),
        _ => EzIconButton(
            config,
            iconSize: appIconSize(config),
            icon: const Icon(Icons.edit_calendar),
            onPressed: createCalendarEvent,
          ),
      };
}
