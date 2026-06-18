/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: Move to widgets and make different versions (analog shout-out)
// TODO: should I make widgets widgets a DIR?

class Clock extends StatefulWidget {
  final EzCP config;

  const Clock(this.config, {super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
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
