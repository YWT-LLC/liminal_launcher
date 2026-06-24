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
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final double _height;
  late final double _width;

  LimSpacer(
    this.config,
    this.appInfo,
    this.lane,
    this.index,
    this.state,
    this.rippleProgress, {
    super.key,
  }) {
    final List<String> data = appInfo.homeList(config, lane)[index].split(widgetSplit);

    _height = double.tryParse(data[1]) ?? config.spacing;
    _width = double.tryParse(data[2]) ?? appIconSize(config);
  }

  @override
  State<LimSpacer> createState() => _LimSpacerState();
}

class _LimSpacerState extends State<LimSpacer> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

  late double height = widget._height;
  late double width = widget._width;

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
  Widget build(BuildContext context) {
    final int numLanes = widget.appInfo.numLanes(widget.config);

    late final EzMenuButton resize = EzMenuButton(
      widget.config,
      onPressed: doNothing,
      label: 'Resize',
      icon: EzIcon(widget.config, Icons.edit),
    );

    late final EzMenuButton remove = EzMenuButton(
      widget.config,
      onPressed: () => widget.appInfo.deleteWS(
        widget.config,
        lane: widget.lane,
        index: widget.index,
      ),
      label: 'Remove',
      icon: EzIcon(widget.config, Icons.delete),
    );

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceType: EzTransitionType.none,
      forceFade: true,
      child: widget.state == AppState.standard
          ? MenuAnchor(
              builder: (_, MenuController controller, __) => GestureDetector(
                onLongPress: () => toggleMenu(controller),
                child: SizedBox(height: height, width: width),
              ),
              menuChildren: <Widget>[resize, remove],
            )
          : EditContainer(
              widget.config,
              menuControl: menuControl,
              menuChildren: <Widget>[
                if (widget.state == AppState.groupEdit && widget.lane != 0)
                  EzMenuButton(
                    widget.config,
                    label: widget.config.isLTR ? 'Move left' : 'Move right',
                    icon: EzIcon(widget.config, Icons.control_camera),
                    onPressed: () => widget.appInfo.moveItemDown(
                      widget.config,
                      lane: widget.lane,
                      index: widget.index,
                    ),
                  ),
                if (widget.state == AppState.groupEdit && widget.lane < (numLanes - 1))
                  EzMenuButton(
                    widget.config,
                    label: widget.config.isLTR ? 'Move right' : 'Move left',
                    icon: EzIcon(widget.config, Icons.control_camera),
                    onPressed: () => widget.appInfo.moveItemUp(
                      widget.config,
                      lane: widget.lane,
                      index: widget.index,
                    ),
                  ),
                resize,
                remove
              ],
              child: GestureDetector(
                onTap: () => toggleMenu(menuControl),
                child: SizedBox(
                  height: height,
                  width: width,
                  child: Center(child: EzIcon(widget.config, Icons.edit)),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}
