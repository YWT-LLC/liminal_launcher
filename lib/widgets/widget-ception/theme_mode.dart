/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:open_ui/open_ui.dart';

//* Core Widget *//

class ThemeModeWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final LimPos pos;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final WidgetSize _size;

  ThemeModeWidget(
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
  State<ThemeModeWidget> createState() => _ThemeModeWidgetState();
}

class _ThemeModeWidgetState extends State<ThemeModeWidget> {
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
      setState(
        () => state = switch (state) {
          AppState.standard => AppState.groupEdit,
          _ => AppState.standard,
        },
      );

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
          builder: (_, MenuController controller, __) => (widget._size == WidgetSize.button)
              ? EzIconButton(
                  widget.config,
                  icon: Icon(widget.config.isDark ? Icons.dark_mode : Icons.light_mode),
                  onPressed: () async {
                    await EzCM.setBool(isDarkThemeKey, !widget.config.isDark);
                    await widget.config.rebuildThemeMode();
                  },
                  onLongPress: () async {
                    await EzCM.remove(isDarkThemeKey);
                    await widget.config.rebuildThemeMode();
                  },
                )
              : GestureDetector(
                  onLongPress: () => canToggleMenu(widget.config, controller),
                  child: EzThemeModeSwitch(widget.config),
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
            icon: Icon(widget.config.isDark ? Icons.dark_mode : Icons.light_mode),
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
}) => <Widget>[
  // Edit
  _EditTM(config, appInfo, initSize: initSize, lane: pos.lane, index: pos.index),

  // Dupe
  EzMenuButton(
    config,
    label: 'Duplicate',
    icon: EzIcon(config, Icons.copy),
    onPressed: () => appInfo.dupeItem(config, editNew: null, lane: pos.lane, index: pos.index),
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

class AddThemeMode extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final WidgetSize size;

  const AddThemeMode(
    this.config, {
    super.key,
    required this.appInfo,
    required this.lane,
    required this.size,
  });

  void onTap() =>
      appInfo.addWidget(config, type: WidWidGetGet.themeMode, editNew: null, lane: lane);

  @override
  Widget build(BuildContext context) => (size == WidgetSize.button)
      ? EzIconButton(
          config,
          onPressed: onTap,
          icon: Icon(config.isDark ? Icons.dark_mode : Icons.light_mode),
        )
      : GestureDetector(
          onTap: onTap,
          child: EzRow(
            config,
            children: <Widget>[
              Text('Theme mode', textAlign: TextAlign.center, style: config.labelStyle),
              config.rowMargin,
              EzDropdownMenu<bool>(
                config,
                dropdownMenuEntries: <DropdownMenuEntry<bool>>[
                  const DropdownMenuEntry<bool>(label: 'selector', value: true),
                ],
                enabled: false,
                widthEntry: 'Widget',
                initialSelection: true,
              ),
            ],
          ),
        );
}

String defaultThemeWidgetEntry() => _themeModeEntry(WidgetSize.button);

String _themeModeEntry(WidgetSize size) => <String>[size.value].join(configSplit);

//* Edit Widget *//

Future<void> _quickResize(
  EzCP config, {
  required AppInfoProvider appInfo,
  required WidgetSize initSize,
  required int lane,
  required int index,
}) async => await appInfo.updateWidget(
  config,
  WidWidGetGet.themeMode,
  _themeModeEntry(initSize == WidgetSize.tile ? WidgetSize.button : WidgetSize.tile),
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
    onPressed: () =>
        _quickResize(config, appInfo: appInfo, initSize: initSize, lane: lane, index: index),
  );
}
