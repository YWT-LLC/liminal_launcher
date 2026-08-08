/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

//* Core Widget *//

class LimSpacer extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final LimPos pos;
  final TileState state;
  final ValueNotifier<double>? rippleProgress;

  final void Function() resizeCallback;

  late final double _height;
  late final double _width;

  LimSpacer(
    this.config, {
    super.key,
    required this.appInfo,
    required this.pos,
    required this.state,
    required this.rippleProgress,
    required this.resizeCallback,
  }) {
    final List<String> data =
        appInfo.homeItem(config, lane: pos.lane, index: pos.index).split(spacerSplit);

    _height = double.tryParse(data[0]) ?? config.spacing;
    _width = double.tryParse(data[1]) ?? appIconSize(config);
  }

  @override
  State<LimSpacer> createState() => _LimSpacerState();
}

class _LimSpacerState extends State<LimSpacer> {
  // Define the build data //

  late TileState state = widget.state;
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
      setState(
        () => state = switch (state) {
          TileState.standard => TileState.groupEdit,
          _ => TileState.standard,
        },
      );

      final Duration animDur = ezDuration(widget.config.animDur);
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

    return ValueListenableBuilder<LimPos?>(
      valueListenable: marked,
      builder: (_, LimPos? markedPos, __) =>
          (markedPos?.lane == widget.pos.lane && markedPos?.index == widget.pos.index)
              ? _LiveSpacer(widget.config)
              : EzAnimSwitch(
                  widget.config,
                  mod: 0.667,
                  forceFade: true,
                  forceType: EzTransitionType.none,
                  child: (state == TileState.standard)
                      ? MenuAnchor(
                          builder: (_, MenuController controller, __) => (markedPos == null)
                              ? GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onLongPress: () async =>
                                      await canToggleMenu(widget.config, controller),
                                  child: SizedBox(height: widget._height, width: widget._width),
                                )
                              : GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(() => marked.value = widget.pos),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: widget.config.colors.tertiaryContainer,
                                        width: widget.config.borderWidth,
                                      ),
                                      borderRadius: EzButtonShape.roundRect.radius,
                                      color: widget.config.colors.tertiary
                                          .withValues(alpha: focusOpacity),
                                    ),
                                    height: widget._height,
                                    width: widget._width,
                                  ),
                                ),
                          menuChildren: _menuChildren(
                            widget.config,
                            appInfo: widget.appInfo,
                            state: state,
                            stateCheck: doNothing,
                            numLanes: numLanes,
                            pos: widget.pos,
                          ),
                        )
                      : EditContainer(
                          widget.config,
                          subAlign: widget.pos.subAlign,
                          menuControl: menuControl,
                          menuChildren: _menuChildren(
                            widget.config,
                            appInfo: widget.appInfo,
                            state: state,
                            stateCheck: widget.resizeCallback,
                            numLanes: numLanes,
                            pos: widget.pos,
                          ),
                          child: EzIconButton(
                            widget.config,
                            icon: const Icon(Icons.space_bar),
                            onPressed: () => toggleMenu(menuControl),
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

List<Widget> _menuChildren(
  EzCP config, {
  required AppInfoProvider appInfo,
  required TileState state,
  required void Function() stateCheck,
  required int numLanes,
  required LimPos pos,
}) =>
    <Widget>[
      // Edit
      _EditSpacer(config, appInfo, pos: pos, stateCheck: stateCheck),

      // Dupe
      EzMenuButton(
        config,
        label: l10n(config).gDupe,
        icon: EzIcon(config, Icons.copy),
        onPressed: () => appInfo.dupeItem(
          config,
          editNew: () async {
            if (!ezRootIsMounted) return;

            await editSpacing(
              config,
              appInfo: appInfo,
              context: ezRootContext,
              startPos: pos,
            );
          },
          lane: pos.lane,
          index: pos.index,
        ),
      ),

      // Move
      if (state == TileState.groupEdit && numLanes > 1) ...<Widget>[
        moveDownLane(config, appInfo, numLanes: numLanes, lane: pos.lane, index: pos.index),
        moveUpLane(config, appInfo, numLanes: numLanes, lane: pos.lane, index: pos.index),
      ],

      // Remove
      removeItem(config, appInfo, lane: pos.lane, index: pos.index),
    ];

//* Add Widget *//

class _LiveSpacer extends StatelessWidget {
  final EzCP config;

  const _LiveSpacer(this.config);

  @override
  Widget build(_) => ValueListenableBuilder<double>(
        valueListenable: editSpacerHeight,
        builder: (_, double height, __) => ValueListenableBuilder<double>(
          valueListenable: editSpacerWidth,
          builder: (_, double width, __) => Container(
            decoration: BoxDecoration(
              border: Border.all(color: config.colors.secondary, width: config.borderWidth),
              borderRadius: EzButtonShape.roundRect.radius,
              color: config.colors.secondary.withValues(alpha: focusOpacity),
            ),
            height: height,
            width: width,
          ),
        ),
      );
}

//* Edit Widget *//

class _EditSpacer extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;

  final LimPos pos;
  final void Function() stateCheck;

  const _EditSpacer(this.config, this.appInfo, {required this.pos, required this.stateCheck});

  @override
  Widget build(_) => EzMenuButton(
        config,
        onPressed: () async {
          if (!ezRootIsMounted) return;
          stateCheck.call();

          await editSpacing(
            config,
            appInfo: appInfo,
            context: ezRootContext,
            startPos: pos,
          );
        },
        label: l10n(config).gEdit,
        icon: EzIcon(config, Icons.edit),
      );
}
