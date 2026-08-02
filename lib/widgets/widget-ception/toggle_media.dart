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

class ToggleMediaWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final LimPos pos;
  final TileState state;
  final ValueNotifier<double>? rippleProgress;

  late final WidgetSize _size;
  late final bool _bigSkips;
  late final bool _lilSkips;

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
    _bigSkips = bool.tryParse(data[1]) ?? true;
    _lilSkips = bool.tryParse(data[2]) ?? false;
  }

  @override
  State<ToggleMediaWidget> createState() => _ToggleMediaWidgetState();
}

class _ToggleMediaWidgetState extends State<ToggleMediaWidget> {
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

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceFade: true,
      forceType: EzTransitionType.none,
      child: switch (state) {
        TileState.standard => MenuAnchor(
            builder: (_, MenuController controller, __) => EzIconButton(
              widget.config,
              icon: (widget._size == WidgetSize.button)
                  ? const Icon(Icons.headphones)
                  : EzRow(
                      widget.config,
                      children: <Widget>[
                        widget.config.rowMargin,

                        // Backwards
                        if (widget._bigSkips) ...<Widget>[
                          GestureDetector(onTap: skipPrev, child: const Icon(Icons.skip_previous)),
                          widget.config.rowSpacer,
                        ],

                        if (widget._lilSkips) ...<Widget>[
                          GestureDetector(onTap: rewind, child: const Icon(Icons.fast_rewind)),
                          widget.config.rowSpacer,
                        ],

                        // Play/pause
                        GestureDetector(onTap: toggleMedia, child: const Icon(Icons.headphones)),

                        // Forwards
                        if (widget._lilSkips) ...<Widget>[
                          widget.config.rowSpacer,
                          GestureDetector(
                              onTap: fastForward, child: const Icon(Icons.fast_forward)),
                        ],

                        if (widget._bigSkips) ...<Widget>[
                          widget.config.rowSpacer,
                          GestureDetector(onTap: skipNext, child: const Icon(Icons.skip_next)),
                        ],
                        widget.config.rowMargin,
                      ],
                    ),
              onPressed: (widget._size == WidgetSize.button) ? toggleMedia : doNothing,
              onLongPress: () async => await canToggleMenu(widget.config, controller),
            ),
            menuChildren: _menuChildren(
              widget.config,
              appInfo: widget.appInfo,
              context: context,
              state: state,
              numLanes: numLanes,
              pos: widget.pos,
              initConfig: _MediaConfig(
                size: widget._size,
                bigSkips: widget._bigSkips,
                lilSkips: widget._lilSkips,
              ),
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
              initConfig: _MediaConfig(
                size: widget._size,
                bigSkips: widget._bigSkips,
                lilSkips: widget._lilSkips,
              ),
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
  required TileState state,
  required int numLanes,
  required LimPos pos,
  required _MediaConfig initConfig,
}) =>
    <Widget>[
      // Edit
      _EditTM(
        config,
        appInfo,
        pContext: context,
        initConfig: initConfig,
        lane: pos.lane,
        index: pos.index,
      ),

      // Dupe
      EzMenuButton(
        config,
        label: l10n(config).gDupe,
        icon: EzIcon(config, Icons.copy),
        onPressed: () => appInfo.dupeItem(
          config,
          editNew: () async {
            if (!ezRootIsMounted) return;
            await _openEdits(
              config,
              appInfo: appInfo,
              pContext: ezRootContext,
              initConfig: initConfig,
              lane: pos.lane,
              index: pos.index,
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
        editNew: () => _openEdits(
          config,
          appInfo: appInfo,
          pContext: pContext,
          initConfig: _MediaConfig(size: size, bigSkips: true, lilSkips: false),
          lane: lane,
          index: appInfo.homeLane(config, lane).length - 1,
        ),
        lane: lane,
      );

  @override
  Widget build(BuildContext context) => EzIconButton(
        config,
        onPressed: onTap,
        icon: (size == WidgetSize.button)
            ? const Icon(Icons.headphones)
            : EzRow(
                config,
                children: <Widget>[
                  config.rowMargin,
                  const Icon(Icons.skip_previous),
                  config.rowSpacer,
                  const Icon(Icons.headphones),
                  config.rowSpacer,
                  const Icon(Icons.skip_next),
                  config.rowMargin,
                ],
              ),
      );
}

String defaultMediaEntry() => _mediaEntry(WidgetSize.tile, bigSkips: true, lilSkips: false);

String _mediaEntry(WidgetSize size, {required bool bigSkips, required bool lilSkips}) =>
    <String>[size.value, bigSkips.toString(), lilSkips.toString()].join(configSplit);

//* Edit Widget *//

class _MediaConfig {
  final WidgetSize size;
  final bool bigSkips;
  final bool lilSkips;

  _MediaConfig({required this.size, required this.bigSkips, required this.lilSkips});
}

Future<void> _openEdits(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext pContext,
  required _MediaConfig initConfig,
  required int lane,
  required int index,
}) async {
  WidgetSize size = initConfig.size;
  bool bigSkips = initConfig.bigSkips;
  bool lilSkips = initConfig.lilSkips;

  await ezModal(
    config,
    context: pContext,
    builder: (_) => StatefulBuilder(
      builder: (_, StateSetter setModal) => ezModalScroll(config, children: <Widget>[
        // Size
        EzFlipFlop(
          config,
          key: UniqueKey(),
          onLabel: l10n(config).gTile,
          offLabel: l10n(config).gButton,
          init: size == WidgetSize.tile,
          onChanged: (bool tile) {
            if (!tile) {
              bigSkips = false;
              lilSkips = false;
            } else {
              if (!bigSkips && !lilSkips) bigSkips = true;
            }

            setModal(() => size = tile ? WidgetSize.tile : WidgetSize.button);
          },
        ),
        config.margin,

        // Preview
        EzIconButton(
          config,
          icon: (size == WidgetSize.button)
              ? const Icon(Icons.headphones)
              : EzRow(
                  config,
                  children: <Widget>[
                    config.rowMargin,

                    // Backwards
                    if (bigSkips) ...<Widget>[const Icon(Icons.skip_previous), config.rowSpacer],

                    if (lilSkips) ...<Widget>[const Icon(Icons.fast_rewind), config.rowSpacer],

                    // Play/pause
                    const Icon(Icons.headphones),

                    // Forwards
                    if (lilSkips) ...<Widget>[config.rowSpacer, const Icon(Icons.fast_forward)],

                    if (bigSkips) ...<Widget>[config.rowSpacer, const Icon(Icons.skip_next)],
                    config.rowMargin,
                  ],
                ),
          onPressed: doNothing,
        ),
        EzDivider(height: config.spacing * 2),

        // Button toggles
        EzSwitchPair(
          config,
          key: ValueKey<String>('big-$bigSkips'),
          value: bigSkips,
          text: l10n(config).togSkip,
          onChanged: (bool? value) {
            if (value == null) return;

            if (value) {
              bigSkips = true;
              if (!lilSkips && (size == WidgetSize.button)) size = WidgetSize.tile;
              setModal(() {});
            } else {
              bigSkips = false;
              if (!lilSkips && (size == WidgetSize.tile)) size = WidgetSize.button;
              setModal(() {});
            }
          },
        ),
        config.spacer,
        EzSwitchPair(
          config,
          key: ValueKey<String>('lil-$lilSkips'),
          value: lilSkips,
          text: l10n(config).togFF,
          onChanged: (bool? value) {
            if (value == null) return;

            if (value) {
              lilSkips = true;
              if (!bigSkips && (size == WidgetSize.button)) size = WidgetSize.tile;
              setModal(() {});
            } else {
              lilSkips = false;
              if (!bigSkips && (size == WidgetSize.tile)) size = WidgetSize.button;
              setModal(() {});
            }
          },
        ),
        config.separator,

        // Note
        Text(
          l10n(config).togSomePlayers,
          textAlign: TextAlign.center,
          style: config.labelStyle,
        ),
        config.separator,
      ]),
    ),
  );

  await appInfo.updateWidget(
    config,
    WidWidGetGet.toggleMedia,
    _mediaEntry(size, bigSkips: bigSkips, lilSkips: lilSkips),
    lane: lane,
    index: index,
  );
}

class _EditTM extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext pContext;
  final _MediaConfig initConfig;
  final int lane;
  final int index;

  const _EditTM(
    this.config,
    this.appInfo, {
    required this.pContext,
    required this.initConfig,
    required this.lane,
    required this.index,
  });

  @override
  Widget build(_) => EzMenuButton(
        config,
        label: l10n(config).gEdit,
        icon: EzIcon(config, Icons.edit),
        onPressed: () => _openEdits(
          config,
          appInfo: appInfo,
          pContext: pContext,
          initConfig: initConfig,
          lane: lane,
          index: index,
        ),
      );
}
