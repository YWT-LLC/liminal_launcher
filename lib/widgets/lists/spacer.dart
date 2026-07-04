/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class LimSpacer extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;
  final void Function() resizeCallback;

  late final double _height;
  late final double _width;

  LimSpacer(
    this.config, {
    super.key,
    required this.appInfo,
    required this.lane,
    required this.index,
    required this.state,
    required this.rippleProgress,
    required this.resizeCallback,
  }) {
    final List<String> data = appInfo.homeItem(config, lane: lane, index: index).split(spacerSplit);

    _height = double.tryParse(data[0]) ?? config.spacing;
    _width = double.tryParse(data[1]) ?? appIconSize(config);
  }

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
            AppState.standard => AppState.groupEdit,
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

    late final EzMenuButton remove =
        removeItem(widget.config, widget.appInfo, lane: widget.lane, index: widget.index);

    late final EzMenuButton resize = EzMenuButton(
      widget.config,
      onPressed: () async {
        if (state == AppState.groupEdit) widget.resizeCallback.call();

        await editSpacer(
          widget.config,
          appInfo: widget.appInfo,
          lane: widget.lane,
          index: widget.index,
        );
      },
      label: 'Resize',
      icon: EzIcon(widget.config, Icons.edit),
    );

    late final EzMenuButton dupe = EzMenuButton(
      widget.config,
      onPressed: () => widget.appInfo.addSpacer(
        widget.config,
        height: widget._height,
        width: widget._width,
        lane: widget.lane,
        index: widget.index,
      ),
      label: 'Duplicate',
      icon: EzIcon(widget.config, Icons.copy),
    );

    return ValueListenableBuilder<(int?, int?)>(
      valueListenable: marked,
      builder: (_, (int?, int?) pos, __) => (pos.$1 == widget.lane && pos.$2 == widget.index)
          ? EditSpacer(widget.config)
          : EzAnimSwitch(
              widget.config,
              mod: 0.667,
              forceType: EzTransitionType.none,
              forceFade: true,
              child: (state == AppState.standard)
                  ? MenuAnchor(
                      builder: (_, MenuController controller, __) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: () => canToggleMenu(widget.config, controller),
                        child: SizedBox(height: widget._height, width: widget._width),
                      ),
                      menuChildren: <Widget>[
                        dupe,
                        resize,
                        remove,
                      ],
                    )
                  : EditContainer(
                      widget.config,
                      menuControl: menuControl,
                      menuChildren: <Widget>[
                        if (numLanes > 1 && widget.lane != 0)
                          moveDownLane(widget.config, widget.appInfo,
                              numLanes: numLanes, lane: widget.lane, index: widget.index),
                        resize,
                        remove,
                        dupe,
                        if (numLanes > 1 && widget.lane < (numLanes - 1))
                          moveUpLane(widget.config, widget.appInfo,
                              numLanes: numLanes, lane: widget.lane, index: widget.index),
                      ],
                      child: EzIconButton(
                        widget.config,
                        icon: const Icon(Icons.space_bar),
                        onPressed: () => canToggleMenu(widget.config, menuControl),
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
