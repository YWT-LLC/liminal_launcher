/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class ThemeModeWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final WidgetSize _size;

  ThemeModeWidget(
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
            menuChildren: widgetMC(
              widget.config,
              widget.appInfo,
              _EditTM(
                widget.config,
                widget.appInfo,
                parentCon: context,
                initSize: widget._size,
                lane: widget.lane,
                index: widget.index,
              ),
              numLanes: numLanes,
              lane: widget.lane,
              index: widget.index,
            ),
          ),
        _ => EditContainer(
            widget.config,
            menuControl: menuControl,
            menuChildren: widgetMC(
              widget.config,
              widget.appInfo,
              _EditTM(
                widget.config,
                widget.appInfo,
                parentCon: context,
                initSize: widget._size,
                lane: widget.lane,
                index: widget.index,
              ),
              numLanes: numLanes,
              lane: widget.lane,
              index: widget.index,
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

class AddThemeMode extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final WidgetSize save;
  final WidgetSize preview;

  const AddThemeMode(
    this.config,
    this.appInfo,
    this.lane, {
    super.key,
    required this.save,
    required this.preview,
  });

  void onTap() => appInfo.addThemeModeWidget(config, lane);

  @override
  Widget build(BuildContext context) => (preview == WidgetSize.button)
      ? EzIconButton(
          config,
          onPressed: onTap,
          icon: Icon(config.isDark ? Icons.dark_mode : Icons.light_mode),
        )
      : GestureDetector(
          onTap: onTap,
          child: EzRow(config, children: <Widget>[
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
          ]),
        );
}

class _EditTM extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext parentCon;
  final WidgetSize initSize;
  final int lane;
  final int index;

  const _EditTM(
    this.config,
    this.appInfo, {
    required this.parentCon,
    required this.initSize,
    required this.lane,
    required this.index,
  });

  @override
  Widget build(_) => EzMenuButton(
        config,
        label: 'Resize',
        icon: EzIcon(config, Icons.edit),
        onPressed: () async {
          final String? choice = await resizeWidgetDialog(config, parentCon, initSize);
          if (choice == null) return;

          await appInfo.updateWidget(
            config,
            WidWidGetGet.themeMode,
            TCC.themeModeEntry(WSConfig.safeLookup(choice)),
            lane: lane,
            index: index,
          );
        },
      );
}
