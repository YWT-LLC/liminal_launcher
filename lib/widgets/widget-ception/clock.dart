/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: get all updates live AF

class ClockWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final String _shape;
  late final String _background;
  late final String _showTime;
  late final String _timeStyle;
  late final String _timeColor;
  late final String _dateType;
  late final String _dateStyle;
  late final String _dateColor;

  ClockWidget(
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

    _shape = data[0];
    _background = data[1];
    _showTime = data[2];
    _timeStyle = data[3];
    _timeColor = data[4];
    _dateType = data[5];
    _dateStyle = data[6];
    _dateColor = data[7];
  }

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

  late EzButtonShape? shape = EBSConfig.lookup(widget._shape);
  late final int? _bCV = _getCV(widget._background);
  late Color? background = _bCV == null ? null : Color(_bCV);

  late bool showTime = bool.tryParse(widget._showTime) ?? true;
  late TxtStile timeStyle = TSConfig.lookup(widget._timeStyle) ?? TxtStile.headline;
  late final int? _tCV = _getCV(widget._timeColor);
  late Color? timeColor = _tCV == null ? null : Color(_tCV);

  late DateType dateType = DTConfig.lookup(widget._dateType);
  late TxtStile dateStyle = TSConfig.lookup(widget._dateStyle) ?? TxtStile.label;
  late final int? _dCV = _getCV(widget._dateColor);
  late Color? dateColor = _dCV == null ? null : Color(_dCV);

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

  int? _getCV(String storage) => (storage == esSystem) ? null : int.tryParse(storage);

  Future<void> openEdits(Set<_Edits> types) async {
    final double iconRadius = widget.config.iconSize / 2;

    await ezModal(
      widget.config,
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, StateSetter setModal) => ezModalScroll(
            widget.config,
            children: <Widget>[
              if (types.contains(_Edits.background)) ...<Widget>[
                // Shape
                Text(
                  'Background shape',
                  style: widget.config.labelStyle,
                  textAlign: TextAlign.center,
                ),
                widget.config.margin,
                RadioGroup<EzButtonShape>(
                  groupValue: shape,
                  onChanged: (EzButtonShape? choice) => setModal(() => shape = choice),
                  child: EzScrollView(
                    widget.config,
                    scrollDirection: Axis.horizontal,
                    thumbVisibility: false,
                    showScrollHint: true,
                    children: EzButtonShape.values
                        .map((EzButtonShape bs) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: widget.config.spacing / 2),
                              child: EzCol(children: <Widget>[
                                EzElevatedButton(
                                  widget.config,
                                  text: bs.name(widget.config.ezL10n),
                                  style: ElevatedButton.styleFrom(shape: bs.shape),
                                  onPressed: () => setModal(() => shape = bs),
                                  onLongPress: () => setModal(() => shape = null),
                                ),
                                widget.config.margin,
                                ExcludeSemantics(
                                  child: EzRadio<EzButtonShape>(widget.config, value: bs),
                                ),
                              ]),
                            ))
                        .toList(),
                  ),
                ),
                widget.config.spacer,

                // Background color
                EzElevatedIconButton(
                  widget.config,
                  onPressed: () async {
                    Color curr = background ??
                        widget.config.colors.surfaceContainer
                            .withValues(alpha: widget.config.textBackgroundOpacity);

                    await ezColorPicker(
                      widget.config,
                      context: context,
                      startColor: curr,
                      onColorChange: (Color choice) => curr = choice,
                      onConfirm: () {
                        setModal(() => background = curr);
                        setState(() {});
                      },
                      onDeny: doNothing,
                    );
                  },
                  onLongPress: () {
                    setModal(() => background = null);
                    setState(() {});
                  },
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.config.colors.primaryContainer,
                        width: widget.config.borderWidth,
                      ),
                    ),
                    child: (background == null || background == Colors.transparent)
                        ? CircleAvatar(
                            backgroundColor: widget.config.colors.surface,
                            foregroundColor: widget.config.colors.onSurface,
                            radius: iconRadius + widget.config.padding,
                            child: EzIcon(
                              widget.config,
                              (background == null) ? Icons.settings : Icons.visibility_off,
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: background,
                            radius: iconRadius + widget.config.padding,
                          ),
                  ),
                  label: 'Background\ncolor',
                  textAlign: TextAlign.center,
                ),
                widget.config.separator,
              ],
              if (types.contains(_Edits.time)) ...<Widget>[
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

                // Time color
                EzElevatedIconButton(
                  widget.config,
                  onPressed: () async {
                    Color curr = timeColor ?? widget.config.colors.onSurface;

                    await ezColorPicker(
                      widget.config,
                      context: context,
                      startColor: curr,
                      onColorChange: (Color choice) => curr = choice,
                      onConfirm: () {
                        setModal(() => timeColor = curr);
                        setState(() {});
                      },
                      onDeny: doNothing,
                    );
                  },
                  onLongPress: () {
                    setModal(() => timeColor = null);
                    setState(() {});
                  },
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.config.colors.primaryContainer,
                        width: widget.config.borderWidth,
                      ),
                    ),
                    child: (timeColor == null || timeColor == Colors.transparent)
                        ? CircleAvatar(
                            backgroundColor: widget.config.colors.surface,
                            foregroundColor: widget.config.colors.onSurface,
                            radius: iconRadius + widget.config.padding,
                            child: EzIcon(
                              widget.config,
                              (timeColor == null) ? Icons.settings : Icons.visibility_off,
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: timeColor,
                            radius: iconRadius + widget.config.padding,
                          ),
                  ),
                  label: 'Time color',
                  textAlign: TextAlign.center,
                ),
                widget.config.separator,
              ],
              if (types.contains(_Edits.date)) ...<Widget>[
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
                      'Date style',
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
                widget.config.spacer,

                // Date color
                EzElevatedIconButton(
                  widget.config,
                  onPressed: () async {
                    Color curr = dateColor ?? widget.config.colors.onSurface;

                    await ezColorPicker(
                      widget.config,
                      context: context,
                      startColor: curr,
                      onColorChange: (Color choice) => curr = choice,
                      onConfirm: () {
                        setModal(() => dateColor = curr);
                        setState(() {});
                      },
                      onDeny: doNothing,
                    );
                  },
                  onLongPress: () {
                    setModal(() => dateColor = null);
                    setState(() {});
                  },
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.config.colors.primaryContainer,
                        width: widget.config.borderWidth,
                      ),
                    ),
                    child: (dateColor == null || dateColor == Colors.transparent)
                        ? CircleAvatar(
                            backgroundColor: widget.config.colors.surface,
                            foregroundColor: widget.config.colors.onSurface,
                            radius: iconRadius + widget.config.padding,
                            child: EzIcon(
                              widget.config,
                              (dateColor == null) ? Icons.settings : Icons.visibility_off,
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: dateColor,
                            radius: iconRadius + widget.config.padding,
                          ),
                  ),
                  label: 'Date color',
                  textAlign: TextAlign.center,
                ),
                widget.config.separator,
              ],
            ],
          ),
        );
      },
    );

    await widget.appInfo.updateWidget(
      widget.config,
      WidWidGetGet.clock,
      TCC.clockEntry(
          shape, background, showTime, timeStyle, timeColor, dateType, dateStyle, dateColor),
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

    late final EzMenuButton remove =
        removeItem(widget.config, widget.appInfo, lane: widget.lane, index: widget.index);

    late final EzMenuButton editBackground = EzMenuButton(
      widget.config,
      label: 'Background',
      icon: EzIcon(widget.config, Icons.edit),
      onPressed: () async => await openEdits(<_Edits>{_Edits.background}),
    );

    late final EzMenuButton editTime = EzMenuButton(
      widget.config,
      label: 'Time',
      icon: EzIcon(widget.config, Icons.edit),
      onPressed: () async => await openEdits(<_Edits>{_Edits.time}),
    );

    late final EzMenuButton editDate = EzMenuButton(
      widget.config,
      label: 'Date',
      icon: EzIcon(widget.config, Icons.edit),
      onPressed: () async => await openEdits(<_Edits>{_Edits.date}),
    );

    // TODO: combine into double anchor
    late final EzMenuButton editAll = EzMenuButton(
      widget.config,
      label: 'All',
      icon: EzIcon(widget.config, Icons.edit),
      onPressed: () async => await openEdits(<_Edits>{_Edits.background, _Edits.time, _Edits.date}),
    );

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceType: EzTransitionType.none,
      forceFade: true,
      child: switch (state) {
        AppState.standard => MenuAnchor(
            builder: (_, MenuController controller, __) => GestureDetector(
              onLongPress: () => canToggleMenu(widget.config, controller),
              child: EzTextBackground(
                widget.config,
                padding: EdgeInsets.all(widget.config.padding),
                shape: shape?.shape,
                backgroundColor: background,
                text: EzCol(
                  mainAxisAlignment: vAlign(widget.config).mainAxis,
                  crossAxisAlignment: hAlign(widget.config).crossAxis,
                  children: <Widget>[
                    if (showTime)
                      Text(
                        TimeOfDay.fromDateTime(now).format(context),
                        style: timeStyle.style(widget.config)?.copyWith(color: timeColor),
                        textAlign: hAlign(widget.config).textAlign,
                      ),
                    if (dateType != DateType.none)
                      Text(
                        DTConfig.buildDate(context, now, dateType),
                        style: dateStyle.style(widget.config)?.copyWith(color: dateColor),
                        textAlign: hAlign(widget.config).textAlign,
                      ),
                  ],
                ),
              ),
            ),
            menuChildren: <Widget>[editBackground, editTime, editDate, editAll, remove],
          ),
        _ => EditContainer(
            widget.config,
            menuControl: menuControl,
            menuChildren: <Widget>[
              if (numLanes > 1)
                moveDownLane(widget.config, widget.appInfo,
                    numLanes: numLanes, lane: widget.lane, index: widget.index),
              ...(numLanes > 1)
                  ? <Widget>[editAll]
                  : <Widget>[editBackground, editTime, editDate, editAll],
              remove,
              if (numLanes > 1)
                moveUpLane(widget.config, widget.appInfo,
                    numLanes: numLanes, lane: widget.lane, index: widget.index),
            ],
            child: EzIconButton(
              widget.config,
              icon: const Icon(Icons.watch),
              onPressed: () => canToggleMenu(widget.config, menuControl),
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

enum _Edits { background, time, date }
