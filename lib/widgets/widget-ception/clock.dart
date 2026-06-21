/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: states && edits
// TODO: analog shout-out for different versions

class ClockWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final List<String>? _extra;
  late final Future<void> Function(String, bool) _save;

  ClockWidget(
    this.config,
    this.appInfo,
    this.lane,
    this.index,
    this.state,
    this.rippleProgress, {
    super.key,
  }) {
    final List<String> data = appInfo.homeList(config, lane)[index].split(widgetSplit);

    _extra = data.length > 2 ? data.sublist(2) : null;

    _save = (_, __) async {};
  }

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  DateTime now = DateTime.now();
  late Timer ticker;

  // Define custom functions //

  void rippling() {
    if (rippleThrottle != null ||
        widget.rippleProgress == null ||
        widget.rippleProgress!.value <= 0) {
      return;
    }

    final Offset wya = ezWya(context);
    final double dx = (wya.dx - lastRipple.dx).abs();
    final double dy = (wya.dy - lastRipple.dy).abs();

    if (dx <= (widget.rippleProgress!.value * widthOf(context)) &&
        dy <= (widget.rippleProgress!.value * heightOf(context))) {
      setState(() => state = switch (state) {
            AppState.standard || AppState.singleEdit => AppState.groupEdit,
            _ => AppState.standard,
          });

      final Duration animDur = ezDuration(widget.config.animDur, mod: rippleMod);
      rippleThrottle = Timer(
        (animDur + const Duration(milliseconds: 50)) - (animDur * widget.rippleProgress!.value),
        () => rippleThrottle = null,
      );
    }
  }

  // Init //

  @override
  void initState() {
    super.initState();
    widget.rippleProgress?.addListener(rippling);

    ticker = homeTime(widget.config)
        ? Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) setState(() => now = DateTime.now());
          })
        : Timer.periodic(const Duration(minutes: 1), (_) {
            if (mounted) setState(() => now = DateTime.now());
          });
  }

  // Return the build //

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
    widget.rippleProgress?.removeListener(rippling);
    ticker.cancel();
    super.dispose();
  }
}
