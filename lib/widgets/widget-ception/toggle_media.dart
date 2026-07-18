/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

//* Core Widget *//

class ToggleMediaWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final LimPos pos;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final WidgetSize _size;

  ToggleMediaWidget(
    this.config,
    this.appInfo,
    this.pos,
    this.state,
    this.rippleProgress, {
    super.key,
  }) {
    final List<String> data = appInfo
        .homeItem(config, lane: pos.lane, index: pos.index)
        .split(widgetSplit)[1]
        .split(configSplit);

    _size = WSConfig.safeLookup(data[0]);
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
            menuChildren: _menuChildren(
              widget.config,
              appInfo: widget.appInfo,
              context: context,
              state: state,
              numLanes: numLanes,
              pos: widget.pos,
              initSize: widget._size,
            ),
          ),
        _ => EditContainer(
            widget.config,
            subAlign: widget.pos.subAlign,
            menuControl: menuControl,
            menuChildren: _menuChildren(
              widget.config,
              appInfo: widget.appInfo,
              context: context,
              state: state,
              numLanes: numLanes,
              pos: widget.pos,
              initSize: widget._size,
            ),
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

List<Widget> _menuChildren(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext context,
  required AppState state,
  required int numLanes,
  required LimPos pos,
  required WidgetSize initSize,
}) =>
    <Widget>[
      // Edit
      _EditTM(
        config,
        appInfo,
        initSize: initSize,
        lane: pos.lane,
        index: pos.index,
      ),

      // Dupe
      EzMenuButton(
        config,
        label: 'Duplicate',
        icon: EzIcon(config, Icons.copy),
        onPressed: () => appInfo.dupeItem(
          config,
          editNew: null,
          lane: pos.lane,
          index: pos.index,
        ),
      ),

      // Move
      if (state == AppState.groupEdit && numLanes > 1) ...<Widget>[
        moveDownLane(config, appInfo, numLanes: numLanes, lane: pos.lane, index: pos.index),
        moveUpLane(config, appInfo, numLanes: numLanes, lane: pos.lane, index: pos.index),
      ],

      // Remove
      removeItem(config, appInfo, lane: pos.lane, index: pos.index),
    ];

//* Add Widget *//

class AddToggleMedia extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext pContext;
  final int lane;
  final WidgetSize size;

  const AddToggleMedia(
    this.config, {
    super.key,
    required this.appInfo,
    required this.pContext,
    required this.lane,
    required this.size,
  });

  void onTap() => appInfo.addWidget(
        config,
        type: WidWidGetGet.toggleMedia,
        editNew: null,
        lane: lane,
      );

  @override
  Widget build(BuildContext context) => EzIconButton(
        config,
        onPressed: onTap,
        icon: (size == WidgetSize.button)
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

String defaultMediaEntry() => _mediaEntry(WidgetSize.tile);

String _mediaEntry(WidgetSize size) => <String>[size.value].join(configSplit);

//* Edit Widget *//

Future<void> _quickResize(
  EzCP config, {
  required AppInfoProvider appInfo,
  required WidgetSize initSize,
  required int lane,
  required int index,
}) async =>
    await appInfo.updateWidget(
      config,
      WidWidGetGet.toggleMedia,
      _mediaEntry(initSize == WidgetSize.tile ? WidgetSize.button : WidgetSize.tile),
      lane: lane,
      index: index,
    );

class _EditTM extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final WidgetSize initSize;
  final int lane;
  final int index;

  const _EditTM(
    this.config,
    this.appInfo, {
    required this.initSize,
    required this.lane,
    required this.index,
  });

  @override
  Widget build(_) => EzMenuButton(
        config,
        label: 'Resize',
        icon: EzIcon(config, Icons.edit),
        onPressed: () => _quickResize(
          config,
          appInfo: appInfo,
          initSize: initSize,
          lane: lane,
          index: index,
        ),
      );
}
