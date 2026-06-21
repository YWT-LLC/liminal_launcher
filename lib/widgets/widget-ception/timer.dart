/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: states, ripples, and edits

class TimerWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final WidgetSize _size;

  TimerWidget(
    this.config,
    this.appInfo,
    this.lane,
    this.index,
    this.state,
    this.rippleProgress, {
    super.key,
  }) {
    final List<String> data = appInfo.homeList(config, lane)[index].split(widgetSplit);

    final WidgetSize size = WSConfig.lookup(data[1]);
    _size = (size == WidgetSize.system) ? bt2WS(config) : size;
  }

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

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
  }

  // Return the build //

  @override
  Widget build(BuildContext context) => switch (widget._size) {
        // TODO: most everything
        WidgetSize.button => EzIconButton(
            widget.config,
            icon: EzIcon(widget.config, Icons.timer_outlined),
            onPressed: () => setTimer(seconds: 60),
          ),
        _ => EzIconButton(
            widget.config,
            icon: EzIcon(widget.config, Icons.timer_outlined),
            onPressed: () => setTimer(seconds: 60),
          ),
      };

  @override
  void dispose() {
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}
