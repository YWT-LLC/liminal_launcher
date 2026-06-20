/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: analog shout-out for different versions

class ClockWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;

  late final List<String>? _extra;
  late final Future<void> Function(String, bool) _save;

  ClockWidget(this.config, this.appInfo, this.lane, this.index, this.state, {super.key}) {
    final List<String> data = appInfo.homeList(config, lane)[index].split(widgetSplit);

    _extra = data.length > 2 ? data.sublist(2) : null;

    _save = (_, __) async {};
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
  Widget build(BuildContext context) => EzTextBackground(
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
      );

  @override
  void dispose() {
    ticker.cancel();
    super.dispose();
  }
}
