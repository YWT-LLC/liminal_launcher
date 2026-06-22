/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: creation, deletion, editing

class LimSpacer extends StatefulWidget {
  final EzCP config;
  final double height;
  final double width;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  const LimSpacer(
    this.config, {
    super.key,
    required this.height,
    required this.width,
    required this.state,
    required this.rippleProgress,
  });

  @override
  State<LimSpacer> createState() => _LimSpacerState();
}

class _LimSpacerState extends State<LimSpacer> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

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
  Widget build(BuildContext context) => switch (widget.state) {
        AppState.standard => SizedBox(height: widget.height, width: widget.width),
        AppState.singleEdit => EditContainer(
            widget.config,
            menuControl: menuControl,
            menuChildren: <Widget>[
              EzMenuButton(
                widget.config,
                onPressed: doNothing,
                label: 'Resize',
                icon: EzIcon(widget.config, Icons.edit),
              ),
              EzMenuButton(
                widget.config,
                onPressed: doNothing,
                label: 'Remove',
                icon: EzIcon(widget.config, Icons.delete),
              ),
            ],
            child: GestureDetector(
              onTap: () => toggleMenu(menuControl),
              child: SizedBox(
                height: widget.height,
                width: widget.width,
                child: Center(child: EzIcon(widget.config, Icons.edit)),
              ),
            ),
          ),
        _ => EditContainer(
            widget.config,
            menuControl: menuControl,
            menuChildren: <Widget>[
              EzMenuButton(
                widget.config,
                onPressed: doNothing,
                label: 'Move',
                icon: EzIcon(widget.config, Icons.control_camera),
              ),
              EzMenuButton(
                widget.config,
                onPressed: doNothing,
                label: 'Resize',
                icon: EzIcon(widget.config, Icons.edit),
              ),
              EzMenuButton(
                widget.config,
                onPressed: doNothing,
                label: 'Remove',
                icon: EzIcon(widget.config, Icons.delete),
              ),
            ],
            child: GestureDetector(
              onTap: () => toggleMenu(menuControl),
              child: SizedBox(
                height: widget.height,
                width: widget.width,
                child: Center(child: EzIcon(widget.config, Icons.edit)),
              ),
            ),
          ),
      };

  @override
  void dispose() {
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}
