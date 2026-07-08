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
    final List<String> data =
        appInfo.homeItem(config, lane: lane, index: index).split(widgetSplit)[1].split(configSplit);

    late final WidgetSize storedWS = WSConfig.safeLookup(data[0]);
    _size = (storedWS == WidgetSize.system) ? bt2WS(config) : storedWS;
  }

  @override
  State<ToggleMediaWidget> createState() => _ToggleMediaWidgetState();
}

class _ToggleMediaWidgetState extends State<ToggleMediaWidget> {
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
      label: 'Resize',
      icon: EzIcon(widget.config, Icons.edit),
      onPressed: () async {
        final String? choice = await resizeWidgetDialog(
          widget.config,
          context,
          widget._size,
        );
        if (choice == null) return;

        await widget.appInfo.updateWidget(
          widget.config,
          WidWidGetGet.toggleMedia,
          TCC.mediaEntry(WSConfig.safeLookup(choice)),
          lane: widget.lane,
          index: widget.index,
        );
      },
    );

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceFade: true,
      forceType: EzTransitionType.none,
      child: switch (state) {
        AppState.standard => MenuAnchor(
            builder: (_, MenuController controller, __) => EzIconButton(
              widget.config,
              icon: (widget._size == WidgetSize.button)
                  ? const Icon(Icons.headphones)
                  : EzRow(widget.config, children: <Widget>[
                      // Previous
                      widget.config.rowMargin,
                      GestureDetector(onTap: skipPrev, child: const Icon(Icons.skip_previous)),
                      widget.config.rowSpacer,

                      // Play/pause
                      GestureDetector(onTap: toggleMedia, child: const Icon(Icons.headphones)),
                      widget.config.rowSpacer,

                      // Next
                      GestureDetector(onTap: skipNext, child: const Icon(Icons.skip_next)),
                      widget.config.rowMargin,
                    ]),
              onPressed: (widget._size == WidgetSize.button) ? toggleMedia : doNothing,
              onLongPress: () => canToggleMenu(widget.config, controller),
            ),
            menuChildren: <Widget>[resize, remove],
          ),
        _ => EditContainer(
            widget.config,
            menuControl: menuControl,
            menuChildren: <Widget>[
              if (numLanes > 1 && widget.lane != 0)
                moveDownLane(widget.config, widget.appInfo,
                    numLanes: numLanes, lane: widget.lane, index: widget.index),
              resize,
              remove,
              if (numLanes > 1 && widget.lane < (numLanes - 1))
                moveUpLane(widget.config, widget.appInfo,
                    numLanes: numLanes, lane: widget.lane, index: widget.index),
            ],
            child: EzIconButton(
              widget.config,
              icon: const Icon(Icons.headphones),
              onPressed: () => toggleMenu(menuControl),
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

class AddToggleMedia extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final WidgetSize save;
  final WidgetSize preview;

  const AddToggleMedia(
    this.config,
    this.appInfo,
    this.lane, {
    super.key,
    required this.save,
    required this.preview,
  });

  void onTap() => appInfo.addToggleMedia(config, lane);

  @override
  Widget build(BuildContext context) => EzIconButton(
        config,
        onPressed: onTap,
        icon: (preview == WidgetSize.button)
            ? const Icon(Icons.headphones)
            : EzRow(config, children: <Widget>[
                config.rowMargin,
                const Icon(Icons.skip_previous),
                config.rowSpacer,
                const Icon(Icons.headphones),
                config.rowSpacer,
                const Icon(Icons.skip_next),
                config.rowMargin,
              ]),
      );
}
