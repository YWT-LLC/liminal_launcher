/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: analog shout-out for different versions
// TODO: short and long press for everything
// TODO: have a tool tipper on the add screen that describes what it does ahead of time
// TODO: at least two, preferably three sizes for everything

class ClockWidget extends StatefulWidget {
  final EzCP config;
  late final WidgetSize _size;
  final AppState state;

  ClockWidget(this.config, WidgetSize size, this.state, {super.key}) {
    _size = (size == WidgetSize.system) ? bt2WS(config) : size;
  }

  @override
  State<ClockWidget> createState() => _ClockState();
}

class _ClockState extends State<ClockWidget> {
  DateTime now = DateTime.now();
  late Timer ticker;

  @override
  void initState() {
    super.initState();

    ticker = homeTime(widget.config)
        ? Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) setState(() => now = DateTime.now());
          })
        : Timer.periodic(const Duration(minutes: 1), (_) {
            if (mounted) setState(() => now = DateTime.now());
          });
  }

  @override
  Widget build(BuildContext context) => switch (widget._size) {
        WidgetSize.system => const SizedBox.shrink(), // override above
        WidgetSize.unbound || _ => EzTextBackground(
            widget.config,
            padding: EdgeInsets.all(widget.config.padding),
            text: EzCol(
              mainAxisAlignment: vAlign(widget.config).mainAxis,
              crossAxisAlignment: hAlign(widget.config).crossAxis,
              children: <Widget>[
                if (homeTime(widget.config))
                  Text(
                    TimeOfDay.fromDateTime(now).format(context),
                    style: widget.config.headlineStyle,
                    textAlign: hAlign(widget.config).textAlign,
                  ),
                if (homeDate(widget.config) != DateType.none)
                  Text(
                    DTConfig.buildDate(context, now, homeDate(widget.config)),
                    style: widget.config.labelStyle,
                    textAlign: hAlign(widget.config).textAlign,
                  ),
              ],
            ),
          ),
      };

  @override
  void dispose() {
    ticker.cancel();
    super.dispose();
  }
}
