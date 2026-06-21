/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: states && edits

class ToggleMediaWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final WidgetSize _size;

  ToggleMediaWidget(
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
  State<ToggleMediaWidget> createState() => _ToggleMediaWidgetState();
}

class _ToggleMediaWidgetState extends State<ToggleMediaWidget> {
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
    final double dy = (wya.dy - lastRipple.dy).abs();

    if (dy <= (widget.rippleProgress!.value * heightOf(context))) {
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
        WidgetSize.button => EzIconButton(
            widget.config,
            iconSize: appIconSize(widget.config),
            icon: const Icon(Icons.headphones),
            onPressed: toggleMedia,
          ),
        _ => EzIconButton(
            widget.config,
            icon: EzRow(widget.config, children: <Widget>[
              // Previous
              widget.config.rowMargin,
              GestureDetector(
                onTap: skipPrev,
                child: Icon(Icons.skip_previous, size: appIconSize(widget.config)),
              ),
              widget.config.rowSpacer,

              // Play/pause
              GestureDetector(
                onTap: toggleMedia,
                child: Icon(Icons.headphones, size: appIconSize(widget.config)),
              ),
              widget.config.rowSpacer,

              // Next
              GestureDetector(
                onTap: skipNext,
                child: Icon(Icons.skip_next, size: appIconSize(widget.config)),
              ),
              widget.config.rowMargin,
            ]),
            onPressed: doNothing,
            onLongPress: doNothing,
          ),
      };

  @override
  void dispose() {
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}
