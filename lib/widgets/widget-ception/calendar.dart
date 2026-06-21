/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: states, ripples, and edits

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
    final List<String> data = appInfo.homeList(config, lane)[index].split(widgetSplit);

    final WidgetSize size = WSConfig.lookup(data[1]);
    _size = (size == WidgetSize.system) ? bt2WS(config) : size;
  }

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  late final TextEditingController eventCon;
  OverlayEntry? overlayEntry;

  // Define custom functions //

  void rippling() {
    if (rippleThrottle != null ||
        widget.rippleProgress == null ||
        widget.rippleProgress!.value <= 0) {
      return;
    }

    final Offset wya = ezWya(context);
    final double dx = (wya.dx - lastRipple.dx).abs();
    final double dy = (wya.dy - lastRipple.dy).abs();

    if (dx <= (widget.rippleProgress!.value * widthOf(context)) &&
        dy <= (widget.rippleProgress!.value * heightOf(context))) {
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

  void onChanged() {
    final String text = eventCon.text.trim();

    (text.isNotEmpty)
        ? ((overlayEntry == null) ? showOverlay() : overlayEntry?.markNeedsBuild())
        : removeOverlay();
  }

  void showOverlay() {
    overlayEntry = textFormOverlay(widget.config, eventCon.text);
    ezRootNav.currentState?.overlay?.insert(overlayEntry!);
  }

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  // Init //

  @override
  void initState() {
    super.initState();
    widget.rippleProgress?.addListener(rippling);

    eventCon = TextEditingController();
    eventCon.addListener(onChanged);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) => switch (widget._size) {
        WidgetSize.button => EzIconButton(
            widget.config,
            iconSize: appIconSize(widget.config),
            icon: const Icon(Icons.edit_calendar),
            onPressed: () async {
              final bool success = await createCalendarEvent();

              if (!success && context.mounted) {
                await showDialog(
                  context: context,
                  builder: (_) => EzAlertDialog(
                    widget.config,
                    title: const Text('Failed', textAlign: TextAlign.center),
                    content: const Text(
                      "There likely isn't a default calendar app.\nShall I self-destruct?",
                      textAlign: TextAlign.center,
                    ),
                    actions: <Widget>[
                      EzMaterialAction(
                        widget.config,
                        text: 'No',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      EzMaterialAction(
                        widget.config,
                        text: 'Yes',
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await ezNoTouch(() async => await widget.appInfo.deleteWidget(
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
              }
            },
          ),
        _ => EzRow(
            widget.config,
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ezTextSize(
                        'Search bar',
                        context: context,
                        style: widget.config.bodyStyle,
                      ).width +
                      widget.config.padding,
                  maxHeight: appIconSize(widget.config),
                ),
                child: NotificationListener<ScrollNotification>(
                  // Block scroll notifications
                  onNotification: (ScrollNotification notification) => true,
                  child: TextFormField(
                    controller: eventCon,
                    decoration: const InputDecoration(hintText: 'Event'),
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    onFieldSubmitted: (_) => createCalendarEvent, // TODO: actually uses text
                  ),
                ),
              ),
              widget.config.rowMargin,
              EzIconButton(
                widget.config,
                icon: const Icon(Icons.edit_calendar),
                iconSize: appIconSize(widget.config),
                onPressed: createCalendarEvent,
              ),
            ],
          )
      };

  @override
  void dispose() {
    widget.rippleProgress?.removeListener(rippling);
    eventCon.removeListener(onChanged);
    eventCon.dispose();
    removeOverlay();
    super.dispose();
  }
}
