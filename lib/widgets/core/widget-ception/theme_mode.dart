/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../../utils/export.dart';
import '../../export.dart';

import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

//* Core Widget *//

class ThemeModeWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final TileState state;
  final LimPos pos;
  final ValueNotifier<double>? rippleProgress;
  final void Function() editReset;

  final List<String> data;
  late final String _tp;
  late final WWGGSize _size;

  ThemeModeWidget(
    this.config,
    this.appInfo,
    this.state,
    this.pos,
    this.rippleProgress,
    this.editReset,
    this.data, {
    super.key,
  }) {
    _tp = data[0]; // Not used here; tracked so local updates don't clobber it
    _size = WSConfig.safeLookup(data[1]);
  }

  @override
  State<ThemeModeWidget> createState() => _ThemeModeWidgetState();
}

class _ThemeModeWidgetState extends State<ThemeModeWidget> {
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
            builder: (_, MenuController controller, __) => WideTile(
              widget.config,
              alignment: widget.pos.subAlign,
              onLongPress: () async => await canToggleMenu(widget.config, menuControl),
              child: (widget._size == WWGGSize.button)
                  ? GestureDetector(
                      onDoubleTap: () async {
                        await EzCM.remove(isDarkThemeKey);
                        await widget.config.rebuildThemeMode();
                      },
                      child: EzIconButton(
                        widget.config,
                        icon: Icon(widget.config.isDark ? Icons.dark_mode : Icons.light_mode),
                        tooltip: l10n(widget.config).thmToggle,
                        onPressed: () async {
                          await EzCM.setBool(isDarkThemeKey, !widget.config.isDark);
                          await widget.config.rebuildThemeMode();
                        },
                      ),
                    )
                  : EzThemeModeSwitch(widget.config),
            ),
            menuChildren: _menuChildren(
              widget.config,
              appInfo: widget.appInfo,
              context: context,
              state: state,
              editReset: widget.editReset,
              numLanes: numLanes,
              pos: widget.pos,
              initConfig: _TMConfig(
                tp: widget._tp,
                size: widget._size,
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
              editReset: widget.editReset,
              numLanes: numLanes,
              pos: widget.pos,
              initConfig: _TMConfig(
                tp: widget._tp,
                size: widget._size,
              ),
            ),
            child: EzIconButton(
              widget.config,
              icon: Icon(widget.config.isDark ? Icons.dark_mode : Icons.light_mode),
              tooltip: l10n(widget.config).thmToggle,
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
  required void Function() editReset,
  required int numLanes,
  required LimPos pos,
  required _TMConfig initConfig,
}) =>
    <Widget>[
      // Edit
      _EditTM(
        config,
        appInfo,
        initConfig: initConfig,
        lane: pos.lane,
        index: pos.index,
      ),

      // Dupe
      EzMenuButton(
        config,
        label: l10n(config).gDupe,
        icon: EzIcon(config, Icons.copy),
        onPressed: () => appInfo.dupeItem(config, editNew: null, lane: pos.lane, index: pos.index),
      ),

      // Reposition
      reposition(config, appInfo, pos, stateCheck: editReset),

      // Move
      if (state == TileState.groupEdit && numLanes > 1) ...<Widget>[
        moveDownLane(config, appInfo, pos, numLanes: numLanes),
        moveUpLane(config, appInfo, pos, numLanes: numLanes),
      ],

      // Remove
      removeItem(config, appInfo, pos),
    ];

//* Add Widget *//

class AddThemeMode extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final WWGGSize size;

  const AddThemeMode(
    this.config, {
    super.key,
    required this.appInfo,
    required this.lane,
    required this.size,
  });

  void onTap() => appInfo.addWidget(
        config,
        type: WWGG.themeMode,
        size: size,
        editNew: null,
        lane: lane,
      );

  @override
  Widget build(BuildContext context) => (size == WWGGSize.button)
      ? EzIconButton(
          config,
          onPressed: onTap,
          icon: Icon(config.isDark ? Icons.dark_mode : Icons.light_mode),
          tooltip: l10n(config).gAdd,
        )
      : GestureDetector(
          onTap: onTap,
          child: MergeSemantics(
            child: EzDropdownMenu<bool>(
              config,
              label: config.ezL10n.ssThemeMode,
              widthEntry: config.ezL10n.ssThemeMode,
              dropdownMenuEntries: <DropdownMenuEntry<bool>>[
                DropdownMenuEntry<bool>(label: l10n(config).thmSelector, value: true),
              ],
              enabled: false,
              initialSelection: true,
            ),
          ),
        );
}

String defaultThemeWidgetEntry(WWGGSize size) => _themeModeEntry(
      tp: nullTPS,
      size: size,
    );

String _themeModeEntry({
  required String tp,
  required WWGGSize size,
}) =>
    <String>[
      tp,
      size.value,
    ].join(configSplit);

//* Edit Widget *//

class _TMConfig {
  final String tp;
  final WWGGSize size;

  _TMConfig({
    required this.tp,
    required this.size,
  });
}

Future<void> _quickResize(
  EzCP config, {
  required AppInfoProvider appInfo,
  required _TMConfig initConfig,
  required int lane,
  required int index,
}) async =>
    await appInfo.updateWidget(
      config,
      WWGG.themeMode,
      _themeModeEntry(
        tp: initConfig.tp,
        size: initConfig.size == WWGGSize.tile ? WWGGSize.button : WWGGSize.tile,
      ),
      lane: lane,
      index: index,
    );

class _EditTM extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final _TMConfig initConfig;
  final int lane;
  final int index;

  const _EditTM(
    this.config,
    this.appInfo, {
    required this.initConfig,
    required this.lane,
    required this.index,
  });

  @override
  Widget build(_) => EzMenuButton(
        config,
        label: l10n(config).gResize,
        icon: EzIcon(config, Icons.edit),
        onPressed: () => _quickResize(
          config,
          appInfo: appInfo,
          initConfig: initConfig,
          lane: lane,
          index: index,
        ),
      );
}
