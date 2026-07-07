/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class ClockWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final EzButtonShape? _shape;
  late final Color? _background;
  late final bool _showTime;
  late final TxtStile _timeStyle;
  late final Color? _timeColor;
  late final DateType _dateType;
  late final TxtStile _dateStyle;
  late final Color? _dateColor;

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

    _shape = EBSConfig.lookup(data[0]);

    late final int? bCV = int.tryParse(data[1]);
    _background = bCV == null ? null : Color(bCV);

    _showTime = bool.tryParse(data[2]) ?? true;
    _timeStyle = TSConfig.lookup(data[3]) ?? TxtStile.headline;

    late final int? tCV = int.tryParse(data[4]);
    _timeColor = tCV == null ? null : Color(tCV);

    _dateType = DTConfig.lookup(data[5]);
    _dateStyle = TSConfig.lookup(data[6]) ?? TxtStile.label;

    late final int? dCV = int.tryParse(data[7]);
    _dateColor = dCV == null ? null : Color(dCV);
  }

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

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

  Future<void> openEdits() async {
    final double iconRadius = widget.config.iconSize / 2;

    _Edits curr = _Edits.background;
    int delta = 0;

    EzButtonShape? shape = widget._shape;
    Color? background = widget._background;

    TxtStile timeStyle = widget._timeStyle;
    Color? timeColor = widget._timeColor;
    bool showTime = widget._showTime;

    DateType dateType = widget._dateType;
    TxtStile dateStyle = widget._dateStyle;
    Color? dateColor = widget._dateColor;

    await ezModal(
      widget.config,
      context: context,
      builder: (_) => StatefulBuilder(builder: (_, StateSetter setModal) {
        void nav(_Edits choice) {
          delta = choice.index - curr.index;
          setModal(() => curr = choice);
        }

        Widget backgroundSettings() => EzScrollView(widget.config, children: <Widget>[
              EzRichText(
                widget.config,
                children: <InlineSpan>[
                  EzPlainText(
                    text: 'Long press any button to reset/use default\n',
                    style: widget.config.labelStyle,
                  ),
                  WidgetSpan(
                    child: Container(
                      height: widget.config.iconSize,
                      width: widget.config.iconSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.config.colors.secondary,
                        border: BoxBorder.all(
                          color: widget.config.colors.onSecondary,
                          width: widget.config.borderWidth,
                        ),
                      ),
                    ),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  EzPlainText(
                    text: ' == current choice\n',
                    style: widget.config.labelStyle,
                  ),
                  WidgetSpan(
                    child: Container(
                      height: widget.config.iconSize,
                      width: widget.config.iconSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.config.colors.tertiary,
                        border: BoxBorder.all(
                          color: widget.config.colors.onTertiary,
                          width: widget.config.borderWidth,
                        ),
                      ),
                    ),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  EzPlainText(
                    text: ' == using default',
                    style: widget.config.labelStyle,
                  ),
                ],
                textAlign: TextAlign.center,
                style: widget.config.labelStyle,
              ),
              widget.config.spacer,

              // Shape
              EzWrap(
                children: EzButtonShape.values
                    .map((EzButtonShape bs) => Padding(
                          padding: EzInsets.wrap(widget.config.spacing),
                          child: EzCol(children: <Widget>[
                            EzElevatedButton(
                              widget.config,
                              text: bs.name(widget.config.ezL10n),
                              style: shape == null
                                  ? (bs == widget.config.buttonShape
                                      ? ElevatedButton.styleFrom(
                                          shape: bs.shape,
                                          foregroundColor: widget.config.colors.onTertiary,
                                          backgroundColor: widget.config.colors.tertiary,
                                        )
                                      : ElevatedButton.styleFrom(shape: bs.shape))
                                  : (bs == shape
                                      ? ElevatedButton.styleFrom(
                                          shape: bs.shape,
                                          foregroundColor: widget.config.colors.onSecondary,
                                          backgroundColor: widget.config.colors.secondary,
                                        )
                                      : ElevatedButton.styleFrom(shape: bs.shape)),
                              onPressed: () => setModal(() => shape = bs),
                              onLongPress: () => setModal(() => shape = null),
                            ),
                          ]),
                        ))
                    .toList(),
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
                    onConfirm: () => setModal(() => background = curr),
                    onDeny: doNothing,
                  );
                },
                onLongPress: () => setModal(() => background = null),
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
            ]);

        Widget timeSettings() => EzScrollView(widget.config, children: <Widget>[
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
                  },
                ),
              ]),
              widget.config.spacer,

              // Time color
              EzElevatedIconButton(
                widget.config,
                enabled: showTime,
                onPressed: () async {
                  Color curr = timeColor ?? widget.config.colors.onSurface;

                  await ezColorPicker(
                    widget.config,
                    context: context,
                    startColor: curr,
                    onColorChange: (Color choice) => curr = choice,
                    onConfirm: () => setModal(() => timeColor = curr),
                    onDeny: doNothing,
                  );
                },
                onLongPress: () => setModal(() => timeColor = null),
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
              widget.config.spacer,

              // Time on/off
              EzSwitchPair(
                key: ValueKey<bool>(showTime),
                widget.config,
                value: showTime,
                text: 'Show time',
                onChanged: (bool? choice) {
                  if (choice == null) return;
                  setModal(() => showTime = choice);
                },
              ),
              widget.config.separator,
            ]);

        Widget dateSettings() => EzScrollView(widget.config, children: <Widget>[
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
                  },
                ),
              ]),
              widget.config.spacer,

              // Date color
              EzElevatedIconButton(
                widget.config,
                enabled: dateType != DateType.none,
                onPressed: () async {
                  Color curr = dateColor ?? widget.config.colors.onSurface;

                  await ezColorPicker(
                    widget.config,
                    context: context,
                    startColor: curr,
                    onColorChange: (Color choice) => curr = choice,
                    onConfirm: () => setModal(() => dateColor = curr),
                    onDeny: doNothing,
                  );
                },
                onLongPress: () => setModal(() => dateColor = null),
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
            ]);

        return EzCol(mainAxisSize: MainAxisSize.max, children: <Widget>[
          EzHeader(widget.config),

          // Switcher
          SegmentedButton<_Edits>(
            segments: _Edits.values
                .map((_Edits et) => ButtonSegment<_Edits>(
                      value: et,
                      label: Text(et.name, textAlign: TextAlign.center),
                    ))
                .toList(),
            selected: <_Edits>{curr},
            showSelectedIcon: false,
            onSelectionChanged: (Set<_Edits> selected) => nav(selected.first),
          ),

          // Settings
          Expanded(
            child: EzFauxCarousel(
              widget.config,
              position: curr.index,
              delta: delta,
              child: switch (curr) {
                _Edits.background => backgroundSettings(),
                _Edits.time => timeSettings(),
                _Edits.date => dateSettings(),
              },
            ),
          ),
          EzDivider(widget.config.spacing * 2),

          // Preview
          EzTextBackground(
            widget.config,
            padding: EdgeInsets.all(widget.config.padding),
            shape: shape ?? EzButtonShape.roundRect,
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
          widget.config.spacer,
        ]);
      }),
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

    ticker = widget._showTime
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

    late final EzMenuButton editAll = EzMenuButton(
      widget.config,
      label: 'Edit',
      icon: EzIcon(widget.config, Icons.edit),
      onPressed: openEdits,
    );

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceFade: true,
      forceType: EzTransitionType.none,
      child: switch (state) {
        AppState.standard => MenuAnchor(
            builder: (_, MenuController controller, __) => GestureDetector(
              onLongPress: () => canToggleMenu(widget.config, controller),
              child: EzTextBackground(
                widget.config,
                padding: EdgeInsets.all(widget.config.padding),
                shape: widget._shape ?? EzButtonShape.roundRect,
                backgroundColor: widget._background,
                text: EzCol(
                  mainAxisAlignment: vAlign(widget.config).mainAxis,
                  crossAxisAlignment: hAlign(widget.config).crossAxis,
                  children: <Widget>[
                    if (widget._showTime)
                      Text(
                        TimeOfDay.fromDateTime(now).format(context),
                        style: widget._timeStyle
                            .style(widget.config)
                            ?.copyWith(color: widget._timeColor),
                        textAlign: hAlign(widget.config).textAlign,
                      ),
                    if (widget._dateType != DateType.none)
                      Text(
                        DTConfig.buildDate(context, now, widget._dateType),
                        style: widget._dateStyle
                            .style(widget.config)
                            ?.copyWith(color: widget._dateColor),
                        textAlign: hAlign(widget.config).textAlign,
                      ),
                  ],
                ),
              ),
            ),
            menuChildren: <Widget>[editAll, remove],
          ),
        _ => EditContainer(
            widget.config,
            menuControl: menuControl,
            menuChildren: <Widget>[
              if (numLanes > 1 && widget.lane != 0)
                moveDownLane(widget.config, widget.appInfo,
                    numLanes: numLanes, lane: widget.lane, index: widget.index),
              editAll,
              remove,
              if (numLanes > 1 && widget.lane < (numLanes - 1))
                moveUpLane(widget.config, widget.appInfo,
                    numLanes: numLanes, lane: widget.lane, index: widget.index),
            ],
            child: EzIconButton(
              widget.config,
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

/// background, time, date
enum _Edits { background, time, date }

/// background, time, date
extension _ETName on _Edits {
  String get name => switch (this) {
        _Edits.background => 'Background',
        _Edits.time => 'Time',
        _Edits.date => 'Date',
      };
}

class AddClock extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;

  const AddClock(this.config, this.appInfo, this.lane, {super.key});

  void onTap() => appInfo.addClock(config, lane);

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    return GestureDetector(
      onTap: onTap,
      child: EzTextBackground(
        config,
        padding: EdgeInsets.all(config.padding),
        text: EzCol(
          mainAxisAlignment: vAlign(config).mainAxis,
          crossAxisAlignment: hAlign(config).crossAxis,
          children: <Widget>[
            Text(
              TimeOfDay.fromDateTime(now).format(context),
              style: config.headlineStyle,
              textAlign: hAlign(config).textAlign,
            ),
            Text(
              DTConfig.buildDate(context, now, DateType.compact),
              style: config.labelStyle,
              textAlign: hAlign(config).textAlign,
            ),
          ],
        ),
      ),
    );
  }
}
