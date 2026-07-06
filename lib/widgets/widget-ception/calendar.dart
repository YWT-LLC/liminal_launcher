/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class CalendarWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final WidgetSize _size;

  CalendarWidget(
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

    final WidgetSize storedWS = WSConfig.lookup(data[0]);
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
                      lane: widget.lane,
                      index: widget.index,
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
          WidWidGetGet.calendar,
          TCC.calendarEntry(WSConfig.lookup(choice)),
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
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: ezTextSize(
                              'Create event',
                              context: context,
                              style: widget.config.bodyStyle,
                            ).width +
                            widget.config.padding,
                        maxHeight: appIconSize(widget.config),
                      ),
                      child: EzScrollBlocker(LimField(
                        controller: eventCon,
                        hintText: 'New event',
                        onChanged: onChanged,
                        onFieldSubmitted: (String entry) async {
                          final bool success = await createCalendarEvent(entry.trim());
                          eventCon.clear();
                          removeOverlay();
                          if (!success && context.mounted) await selfDestruct();
                        },
                      )),
                    ),
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
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    ezTextSize('Create event', context: context, style: config.bodyStyle).width +
                        config.padding,
                maxHeight: appIconSize(config),
              ),
              child: LimField(
                onTap: onTap,
                readOnly: true,
                hintText: 'New event',
              ),
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
