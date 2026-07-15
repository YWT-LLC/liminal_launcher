/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: make sure it works with task apps, and make a setting for calendar appearance vs task appearance. update class name?

class CalendarWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final LimPos pos;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final WidgetSize _size;

  CalendarWidget(
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

    final WidgetSize storedWS = WSConfig.safeLookup(data[0]);
    _size = (storedWS == WidgetSize.system) ? bt2WS(config) : storedWS;
  }

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

  final TextEditingController eventCon = TextEditingController();
  OverlayEntry? overlayEntry;

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

  void onChanged(String text) => text.isEmpty
      ? removeOverlay()
      : ((overlayEntry == null) ? showOverlay() : overlayEntry!.markNeedsBuild());

  void showOverlay() {
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: safeTop(context),
        left: widget.config.marginVal,
        right: widget.config.marginVal,
        child: Material(
          type: MaterialType.transparency,
          child: IgnorePointer(
            child: Container(
              padding: EdgeInsets.all(widget.config.marginVal),
              decoration: BoxDecoration(
                color: widget.config.colors.surfaceContainer,
                border: Border.all(
                  color: widget.config.colors.secondaryContainer,
                  width: widget.config.borderWidth,
                ),
                borderRadius: widget.config.textRadius,
              ),
              child: Text(
                eventCon.text,
                style: widget.config.bodyStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
    ezRootNav.currentState?.overlay?.insert(overlayEntry!);
  }

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  Future<dynamic> selfDestruct() => showDialog(
        context: context,
        builder: (_) => EzAlertDialog(
          widget.config,
          title: const Text('Failed', textAlign: TextAlign.center),
          content: const Text(
            "There likely isn't a default calendar app.\nShall I self-destruct?",
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            EzAction(
              widget.config,
              text: 'No',
              onPressed: () => Navigator.of(context).pop(),
            ),
            EzAction(
              widget.config,
              text: 'Yes',
              onPressed: () async {
                Navigator.of(context).pop();
                await ezNoTouch(() async => await widget.appInfo.removeItem(
                      widget.config,
                      lane: widget.pos.lane,
                      index: widget.pos.index,
                    ));
              },
              isDestructiveAction: true,
              isDefaultAction: true,
            ),
          ],
          needsClose: false,
        ),
      );

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

    late final double textWidth =
        ezTextSize('Create event', context: context, style: widget.config.bodyStyle).width;

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
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: () async {
                      final bool success = await createCalendarEvent(null);
                      if (!success && context.mounted) await selfDestruct();
                    },
                    onLongPress: () => canToggleMenu(widget.config, controller),
                  )
                : EzRow(widget.config, children: <Widget>[
                    EzScrollBlocker(EzTextField(
                      controller: eventCon,
                      constraints: BoxConstraints(
                        maxHeight: appIconSize(widget.config),
                        maxWidth: textWidth + widget.config.padding,
                      ),
                      errorConstraints:
                          BoxConstraints(maxWidth: (textWidth * 2) + widget.config.padding),
                      hintText: 'New event',
                      onChanged: onChanged,
                      onFieldSubmitted: (String entry) async {
                        final bool success = await createCalendarEvent(entry.trim());
                        eventCon.clear();
                        removeOverlay();
                        if (!success && context.mounted) await selfDestruct();
                      },
                      validator: null,
                    )),
                    widget.config.rowMargin,
                    EzIconButton(
                      widget.config,
                      icon: const Icon(Icons.edit_calendar),
                      onPressed: () async {
                        final bool success = await createCalendarEvent(eventCon.text);
                        eventCon.clear();
                        removeOverlay();
                        if (!success && context.mounted) await selfDestruct();
                      },
                      onLongPress: () => canToggleMenu(widget.config, controller),
                    ),
                  ]),
            menuChildren: widgetMC(
              widget.config,
              widget.appInfo,
              _EditCalendar(
                widget.config,
                widget.appInfo,
                parentCon: context,
                initSize: widget._size,
                lane: widget.pos.lane,
                index: widget.pos.index,
              ),
              numLanes: numLanes,
              lane: widget.pos.lane,
              index: widget.pos.index,
            ),
          ),
        _ => EditContainer(
            widget.config,
            subAlign: widget.pos.subAlign,
            menuControl: menuControl,
            menuChildren: widgetMC(
              widget.config,
              widget.appInfo,
              _EditCalendar(
                widget.config,
                widget.appInfo,
                parentCon: context,
                initSize: widget._size,
                lane: widget.pos.lane,
                index: widget.pos.index,
              ),
              numLanes: numLanes,
              lane: widget.pos.lane,
              index: widget.pos.index,
            ),
            child: EzIconButton(
              widget.config,
              icon: const Icon(Icons.edit_calendar),
              onPressed: () => toggleMenu(menuControl),
            ),
          ),
      },
    );
  }

  @override
  void dispose() {
    removeOverlay();
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}

class AddCalendar extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final WidgetSize save;
  final WidgetSize preview;

  const AddCalendar(
    this.config,
    this.appInfo,
    this.lane, {
    super.key,
    required this.save,
    required this.preview,
  });

  void onTap() => appInfo.addCalendar(config, lane);

  @override
  Widget build(BuildContext context) => (preview == WidgetSize.button)
      ? EzIconButton(
          config,
          onPressed: onTap,
          icon: const Icon(Icons.edit_calendar),
        )
      : GestureDetector(
          onTap: onTap,
          child: EzRow(config, children: <Widget>[
            EzTextField(
              constraints: BoxConstraints(
                maxHeight: appIconSize(config),
                maxWidth:
                    ezTextSize('Create event', context: context, style: config.bodyStyle).width +
                        config.padding,
              ),
              hintText: 'New event',
              onTap: onTap,
              readOnly: true,
              validator: null,
            ),
            config.rowMargin,
            EzIconButton(
              config,
              icon: const Icon(Icons.edit_calendar),
              onPressed: onTap,
            ),
          ]),
        );
}

class _EditCalendar extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext parentCon;
  final WidgetSize initSize;
  final int lane;
  final int index;

  const _EditCalendar(
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
            WidWidGetGet.calendar,
            TCC.calendarEntry(WSConfig.safeLookup(choice)),
            lane: lane,
            index: index,
          );
        },
      );
}
