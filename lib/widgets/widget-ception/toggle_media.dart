/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

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

  final MenuController menuControl = MenuController();
  late WidgetSize size = widget._size;

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

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceType: EzTransitionType.none,
      forceFade: true,
      child: switch (state) {
        AppState.standard || AppState.singleEdit => switch (size) {
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
                onLongPress: doNothing, // TODO: menu anchor for delete, resize
              ),
          },
        _ => EditContainer(
            widget.config,
            menuControl: menuControl,
            menuChildren: <Widget>[
              if (numLanes > 1 && widget.lane != 0)
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
              if (numLanes > 1 && widget.lane < (numLanes - 1))
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
              EzMenuButton(
                widget.config,
                label: 'Resize',
                icon: EzIcon(widget.config, Icons.edit),
                onPressed: () async {
                  final String? choice = await resizeWidgetDialog(
                    widget.config,
                    context,
                    size,
                  );
                  if (choice == null) return;

                  final WidgetSize trueChoice = WSConfig.lookup(choice);
                  await widget.appInfo.updateWidget(
                    widget.config,
                    WidWidGetGet.toggleMedia,
                    trueChoice,
                    extra: null,
                    lane: widget.lane,
                    index: widget.index,
                    notify: false,
                  );
                  setState(() => size = trueChoice);
                },
              ),
              EzMenuButton(
                widget.config,
                label: 'Remove',
                icon: EzIcon(widget.config, Icons.delete),
                onPressed: () => widget.appInfo.deleteWidget(
                  widget.config,
                  lane: widget.lane,
                  index: widget.index,
                ),
              ),
            ],
            child: EzIconButton(
              widget.config,
              iconSize: appIconSize(widget.config),
              icon: const Icon(Icons.headphones),
              onPressed: () => menuControl.isOpen ? menuControl.close() : menuControl.open(),
            ),
          ),
      },
    );
  }

  @override
  void dispose() {
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}
