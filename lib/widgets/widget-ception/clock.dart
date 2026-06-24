/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: when the top/bottom layers are ready, add a clock to the top layer by default

class ClockWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final String _showTime;
  late final String _dateType;
  late final String _timeStyle;
  late final String _dateStyle;

  ClockWidget(
    this.config,
    this.appInfo,
    this.lane,
    this.index,
    this.state,
    this.rippleProgress, {
    super.key,
  }) {
    final List<String> data = appInfo.homeList(config, lane)[index].split(widgetSplit);

    _showTime = data[1];
    _dateType = data[2];
    _timeStyle = data[3];
    _dateStyle = data[4];
  }

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

  late bool showTime = bool.tryParse(widget._showTime) ?? true;
  late DateType dateType = DTConfig.lookup(widget._dateType);
  late TxtStile timeStyle = TSConfig.lookup(widget._timeStyle) ?? TxtStile.headline;
  late TxtStile dateStyle = TSConfig.lookup(widget._dateStyle) ?? TxtStile.label;

  DateTime now = DateTime.now();
  late Timer ticker;

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

  Future<void> openEdits() async {
    await ezModal(
      widget.config,
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, StateSetter setModal) => ezModalScroll(
            widget.config,
            children: <Widget>[
              // Time on/off
              EzSwitchPair(
                key: ValueKey<bool>(showTime),
                widget.config,
                value: showTime,
                text: 'Show time',
                onChanged: (bool? choice) {
                  if (choice == null) return;
                  setModal(() => showTime = choice);
                  setState(() {});
                },
              ),
              widget.config.spacer,

              // Time style
              EzRow(widget.config, children: <Widget>[
                Flexible(
                  child: Text(
                    'Time style',
                    textAlign: TextAlign.center,
                    style: timeStyle.style(widget.config),
                  ),
                ),
                widget.config.rowMargin,
                EzDropdownMenu<TxtStile>(
                  widget.config,
                  enabled: showTime,
                  enableSearch: false,
                  initialSelection: timeStyle,
                  widthEntry: TxtStile.display.value,
                  dropdownMenuEntries: TxtStile.values
                      .map((TxtStile ts) => DropdownMenuEntry<TxtStile>(
                            value: ts,
                            label: ezCamelToTitle(ts.value),
                          ))
                      .toList(),
                  textStyle: timeStyle.style(widget.config),
                  onSelected: (TxtStile? choice) {
                    if (choice == null) return;
                    setModal(() => timeStyle = choice);
                    setState(() {});
                  },
                ),
              ]),
              widget.config.spacer,

              // Date type
              EzRow(widget.config, children: <Widget>[
                Flexible(
                  child: Text(
                    'Date type',
                    textAlign: TextAlign.center,
                    style: widget.config.bodyStyle,
                  ),
                ),
                widget.config.rowMargin,
                EzDropdownMenu<DateType>(
                  widget.config,
                  enableSearch: false,
                  initialSelection: dateType,
                  widthEntry: DateType.compact.value,
                  dropdownMenuEntries: DateType.values
                      .map((DateType dt) => DropdownMenuEntry<DateType>(
                            value: dt,
                            label: ezCamelToTitle(dt.value),
                          ))
                      .toList(),
                  onSelected: (DateType? choice) {
                    if (choice == null) return;
                    setModal(() => dateType = choice);
                    setState(() {});
                  },
                ),
              ]),
              widget.config.spacer,

              // Date style
              EzRow(widget.config, children: <Widget>[
                Flexible(
                  child: Text(
                    'Time style',
                    textAlign: TextAlign.center,
                    style: dateStyle.style(widget.config),
                  ),
                ),
                widget.config.rowMargin,
                EzDropdownMenu<TxtStile>(
                  widget.config,
                  enabled: dateType != DateType.none,
                  enableSearch: false,
                  initialSelection: dateStyle,
                  widthEntry: TxtStile.display.value,
                  dropdownMenuEntries: TxtStile.values
                      .map((TxtStile ts) => DropdownMenuEntry<TxtStile>(
                            value: ts,
                            label: ezCamelToTitle(ts.value),
                          ))
                      .toList(),
                  textStyle: dateStyle.style(widget.config),
                  onSelected: (TxtStile? choice) {
                    if (choice == null) return;
                    setModal(() => dateStyle = choice);
                    setState(() {});
                  },
                ),
              ]),
              widget.config.separator,
            ],
          ),
        );
      },
    );

    await widget.appInfo.updateClock(
      widget.config,
      <String>[showTime.toString(), timeStyle.value, dateType.value, dateStyle.value],
      lane: widget.lane,
      index: widget.index,
    );
  }

  // Init //

  @override
  void initState() {
    super.initState();
    widget.rippleProgress?.addListener(rippling);

    ticker = showTime
        ? Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) setState(() => now = DateTime.now());
          })
        : Timer.periodic(const Duration(minutes: 1), (_) {
            if (mounted) setState(() => now = DateTime.now());
          });
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final int numLanes = widget.appInfo.numLanes(widget.config);

    late final EzMenuButton edit = EzMenuButton(
      widget.config,
      label: 'Edit',
      icon: EzIcon(widget.config, Icons.edit),
      onPressed: openEdits,
    );

    late final EzMenuButton remove = EzMenuButton(
      widget.config,
      label: 'Remove',
      icon: EzIcon(widget.config, Icons.delete),
      onPressed: () => widget.appInfo.deleteWidget(
        widget.config,
        lane: widget.lane,
        index: widget.index,
      ),
    );

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceType: EzTransitionType.none,
      forceFade: true,
      child: switch (state) {
        AppState.standard || AppState.singleEdit => MenuAnchor(
            builder: (_, MenuController controller, __) => GestureDetector(
              onLongPress: () => toggleMenu(controller),
              child: EzTextBackground(
                widget.config,
                padding: EdgeInsets.all(widget.config.padding),
                text: EzCol(
                  mainAxisAlignment: vAlign(widget.config).mainAxis,
                  crossAxisAlignment: hAlign(widget.config).crossAxis,
                  children: <Widget>[
                    if (showTime)
                      Text(
                        TimeOfDay.fromDateTime(now).format(context),
                        style: timeStyle.style(widget.config),
                        textAlign: hAlign(widget.config).textAlign,
                      ),
                    if (dateType != DateType.none)
                      Text(
                        DTConfig.buildDate(context, now, dateType),
                        style: dateStyle.style(widget.config),
                        textAlign: hAlign(widget.config).textAlign,
                      ),
                  ],
                ),
              ),
            ),
            menuChildren: <Widget>[edit, remove],
          ),
        _ => EditContainer(
            widget.config,
            menuControl: menuControl,
            menuChildren: <Widget>[
              if (numLanes > 1 && widget.lane != 0)
                EzMenuButton(
                  widget.config,
                  label: widget.config.isLTR ? 'Move left' : 'Move right',
                  icon: EzIcon(widget.config, Icons.control_camera),
                  onPressed: () => widget.appInfo.moveItemDown(
                    widget.config,
                    lane: widget.lane,
                    index: widget.index,
                  ),
                ),
              if (numLanes > 1 && widget.lane < (numLanes - 1))
                EzMenuButton(
                  widget.config,
                  label: widget.config.isLTR ? 'Move right' : 'Move left',
                  icon: EzIcon(widget.config, Icons.control_camera),
                  onPressed: () => widget.appInfo.moveItemUp(
                    widget.config,
                    lane: widget.lane,
                    index: widget.index,
                  ),
                ),
              edit,
              remove,
            ],
            child: EzIconButton(
              widget.config,
              iconSize: appIconSize(widget.config),
              icon: const Icon(Icons.watch),
              onPressed: () => toggleMenu(menuControl),
            ),
          ),
      },
    );
  }

  @override
  void dispose() {
    ticker.cancel();
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}
