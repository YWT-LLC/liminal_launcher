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
  final ListAlignment hAlign;
  final ListAlignment vAlign;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final EzButtonShape _shape;
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
    this.hAlign,
    this.vAlign,
    this.state,
    this.rippleProgress, {
    super.key,
  }) {
    final List<String> data =
        appInfo.homeItem(config, lane: lane, index: index).split(widgetSplit)[1].split(configSplit);

    _shape = EBSConfig.safeLookup(data[0]);

    late final int? bCV = int.tryParse(data[1]);
    _background = bCV == null ? null : Color(bCV);

    _showTime = bool.tryParse(data[2]) ?? true;
    _timeStyle = TSConfig.lookup(data[3]) ?? TxtStile.headline;

    late final int? tCV = int.tryParse(data[4]);
    _timeColor = tCV == null ? null : Color(tCV);

    _dateType = DTConfig.safeLookup(data[5]);
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
                shape: widget._shape,
                backgroundColor: widget._background,
                text: EzCol(
                  mainAxisAlignment: widget.vAlign.mainAxis,
                  crossAxisAlignment: widget.hAlign.crossAxis,
                  children: <Widget>[
                    if (widget._showTime)
                      Text(
                        TimeOfDay.fromDateTime(now).format(context),
                        style: widget._timeStyle
                            .style(widget.config)
                            ?.copyWith(color: widget._timeColor),
                        textAlign: widget.hAlign.textAlign,
                      ),
                    if (widget._dateType != DateType.none)
                      Text(
                        DTConfig.buildDate(context, now, widget._dateType),
                        style: widget._dateStyle
                            .style(widget.config)
                            ?.copyWith(color: widget._dateColor),
                        textAlign: widget.hAlign.textAlign,
                      ),
                  ],
                ),
              ),
            ),
            menuChildren: widgetMC(
              widget.config,
              widget.appInfo,
              _EditClock(
                widget.config,
                widget.appInfo,
                _ClockConfig(
                  widget._shape,
                  widget._background,
                  widget._timeStyle,
                  widget._timeColor,
                  widget._showTime,
                  widget._dateType,
                  widget._dateStyle,
                  widget._dateColor,
                ),
                lane: widget.lane,
                index: widget.index,
                hAlign: widget.hAlign,
                vAlign: widget.vAlign,
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
              _EditClock(
                widget.config,
                widget.appInfo,
                _ClockConfig(
                  widget._shape,
                  widget._background,
                  widget._timeStyle,
                  widget._timeColor,
                  widget._showTime,
                  widget._dateType,
                  widget._dateStyle,
                  widget._dateColor,
                ),
                lane: widget.lane,
                index: widget.index,
                hAlign: widget.hAlign,
                vAlign: widget.vAlign,
              ),
              numLanes: numLanes,
              lane: widget.lane,
              index: widget.index,
            ),
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

class _EditClock extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final _ClockConfig initConfig;
  final int lane;
  final int index;
  final ListAlignment hAlign;
  final ListAlignment vAlign;

  const _EditClock(
    this.config,
    this.appInfo,
    this.initConfig, {
    required this.lane,
    required this.index,
    required this.hAlign,
    required this.vAlign,
  });

  @override
  Widget build(BuildContext context) => EzMenuButton(
        config,
        icon: EzIcon(config, Icons.edit),
        onPressed: () async {
          final double iconRadius = config.iconSize / 2;

          _Edits curr = _Edits.background;
          int delta = 0;

          EzButtonShape shape = initConfig.shape;
          Color? background = initConfig.background;

          TxtStile timeStyle = initConfig.timeStyle;
          Color? timeColor = initConfig.timeColor;
          bool showTime = initConfig.showTime;

          DateType dateType = initConfig.dateType;
          TxtStile dateStyle = initConfig.dateStyle;
          Color? dateColor = initConfig.dateColor;

          await ezModal(
            config,
            context: context,
            builder: (_) => StatefulBuilder(builder: (_, StateSetter setModal) {
              void nav(_Edits choice) {
                delta = choice.index - curr.index;
                setModal(() => curr = choice);
              }

              Widget backgroundSettings() => EzScrollView(config, children: <Widget>[
                    // Shape
                    Text(
                      'Background shape',
                      textAlign: TextAlign.center,
                      style: config.labelStyle,
                    ),
                    EzWrap(
                      children: <EzButtonShape>[
                        EzButtonShape.pill,
                        EzButtonShape.rect,
                        EzButtonShape.roundRect,
                        EzButtonShape.jewel,
                      ]
                          .map((EzButtonShape bs) => Padding(
                                padding: EzInsets.wrap(config.spacing),
                                child: EzCol(children: <Widget>[
                                  EzElevatedButton(
                                    config,
                                    text: bs.name(config.ezL10n),
                                    textStyle: bs == shape
                                        ? config.bodyStyle?.copyWith(color: config.colors.onPrimary)
                                        : config.bodyStyle,
                                    style: bs == shape
                                        ? ElevatedButton.styleFrom(
                                            shape: bs.shape,
                                            foregroundColor: config.colors.onPrimary,
                                            backgroundColor: config.colors.primary,
                                          )
                                        : ElevatedButton.styleFrom(shape: bs.shape),
                                    onPressed: () => setModal(() => shape = bs),
                                  ),
                                ]),
                              ))
                          .toList(),
                    ),
                    config.separator,

                    // Background color
                    EzElevatedIconButton(
                      config,
                      onPressed: () async {
                        Color curr = background ??
                            config.colors.surfaceContainer
                                .withValues(alpha: config.textBackgroundOpacity);

                        await ezColorPicker(
                          config,
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
                            color: config.colors.primaryContainer,
                            width: config.borderWidth,
                          ),
                        ),
                        child: (background == null || background == Colors.transparent)
                            ? CircleAvatar(
                                backgroundColor: config.colors.surface,
                                foregroundColor: config.colors.onSurface,
                                radius: iconRadius + config.padding,
                                child: EzIcon(
                                  config,
                                  (background == null) ? Icons.settings : Icons.visibility_off,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: background,
                                radius: iconRadius + config.padding,
                              ),
                      ),
                      label: 'Background\ncolor',
                      textAlign: TextAlign.center,
                    ),
                  ]);

              Widget timeSettings() => EzScrollView(config, children: <Widget>[
                    // Time style
                    EzRow(config, children: <Widget>[
                      Flexible(
                        child: Text(
                          'Time style',
                          textAlign: TextAlign.center,
                          style: timeStyle.style(config),
                        ),
                      ),
                      config.rowMargin,
                      EzDropdownMenu<TxtStile>(
                        config,
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
                        textStyle: timeStyle.style(config),
                        onSelected: (TxtStile? choice) {
                          if (choice == null) return;
                          setModal(() => timeStyle = choice);
                        },
                      ),
                    ]),
                    config.spacer,

                    // Time color
                    EzElevatedIconButton(
                      config,
                      enabled: showTime,
                      onPressed: () async {
                        Color curr = timeColor ?? config.colors.onSurface;

                        await ezColorPicker(
                          config,
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
                            color: config.colors.primaryContainer,
                            width: config.borderWidth,
                          ),
                        ),
                        child: (timeColor == null || timeColor == Colors.transparent)
                            ? CircleAvatar(
                                backgroundColor: config.colors.surface,
                                foregroundColor: config.colors.onSurface,
                                radius: iconRadius + config.padding,
                                child: EzIcon(
                                  config,
                                  (timeColor == null) ? Icons.settings : Icons.visibility_off,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: timeColor,
                                radius: iconRadius + config.padding,
                              ),
                      ),
                      label: 'Time color',
                      textAlign: TextAlign.center,
                    ),
                    config.spacer,

                    // Time on/off
                    EzSwitchPair(
                      key: ValueKey<bool>(showTime),
                      config,
                      value: showTime,
                      text: 'Show time',
                      onChanged: (bool? choice) {
                        if (choice == null) return;
                        setModal(() => showTime = choice);
                      },
                    ),
                  ]);

              Widget dateSettings() => EzScrollView(config, children: <Widget>[
                    // Date type
                    EzRow(config, children: <Widget>[
                      Flexible(
                        child: Text(
                          'Date type',
                          textAlign: TextAlign.center,
                          style: config.bodyStyle,
                        ),
                      ),
                      config.rowMargin,
                      EzDropdownMenu<DateType>(
                        config,
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
                    config.spacer,

                    // Date style
                    EzRow(config, children: <Widget>[
                      Flexible(
                        child: Text(
                          'Date style',
                          textAlign: TextAlign.center,
                          style: dateStyle.style(config),
                        ),
                      ),
                      config.rowMargin,
                      EzDropdownMenu<TxtStile>(
                        config,
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
                        textStyle: dateStyle.style(config),
                        onSelected: (TxtStile? choice) {
                          if (choice == null) return;
                          setModal(() => dateStyle = choice);
                        },
                      ),
                    ]),
                    config.spacer,

                    // Date color
                    EzElevatedIconButton(
                      config,
                      enabled: dateType != DateType.none,
                      onPressed: () async {
                        Color curr = dateColor ?? config.colors.onSurface;

                        await ezColorPicker(
                          config,
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
                            color: config.colors.primaryContainer,
                            width: config.borderWidth,
                          ),
                        ),
                        child: (dateColor == null || dateColor == Colors.transparent)
                            ? CircleAvatar(
                                backgroundColor: config.colors.surface,
                                foregroundColor: config.colors.onSurface,
                                radius: iconRadius + config.padding,
                                child: EzIcon(
                                  config,
                                  (dateColor == null) ? Icons.settings : Icons.visibility_off,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: dateColor,
                                radius: iconRadius + config.padding,
                              ),
                      ),
                      label: 'Date color',
                      textAlign: TextAlign.center,
                    ),
                  ]);

              return EzCol(mainAxisSize: MainAxisSize.max, children: <Widget>[
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
                config.spacer,

                // Settings
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragEnd: (DragEndDetails details) {
                      if (details.primaryVelocity == null) return;

                      if (details.primaryVelocity! < -ezSwipeV) {
                        // RTL -> nav right
                        if (curr.index < 2) nav(_Edits.values[curr.index + 1]);
                      }

                      if (details.primaryVelocity! > ezSwipeV) {
                        // LTR -> nav left
                        if (curr.index > 0) nav(_Edits.values[curr.index - 1]);
                      }
                    },
                    child: EzFauxCarousel(
                      config,
                      position: curr.index,
                      delta: delta,
                      child: switch (curr) {
                        _Edits.background => backgroundSettings(),
                        _Edits.time => timeSettings(),
                        _Edits.date => dateSettings(),
                      },
                    ),
                  ),
                ),
                config.divider,

                // Preview
                EzTextBackground(
                  config,
                  padding: EdgeInsets.all(config.padding),
                  shape: shape,
                  backgroundColor: background,
                  text: EzCol(
                    mainAxisAlignment: vAlign.mainAxis,
                    crossAxisAlignment: hAlign.crossAxis,
                    children: <Widget>[
                      if (showTime)
                        Text(
                          TimeOfDay.fromDateTime(DateTime.now()).format(context),
                          style: timeStyle.style(config)?.copyWith(color: timeColor),
                          textAlign: hAlign.textAlign,
                        ),
                      if (dateType != DateType.none)
                        Text(
                          DTConfig.buildDate(context, DateTime.now(), dateType),
                          style: dateStyle.style(config)?.copyWith(color: dateColor),
                          textAlign: hAlign.textAlign,
                        ),
                    ],
                  ),
                ),
                config.separator,
              ]);
            }),
          );

          await appInfo.updateWidget(
            config,
            WidWidGetGet.clock,
            TCC.clockEntry(
                shape, background, showTime, timeStyle, timeColor, dateType, dateStyle, dateColor),
            lane: lane,
            index: index,
          );
        },
      );
}

class _ClockConfig {
  EzButtonShape shape;
  Color? background;

  TxtStile timeStyle;
  Color? timeColor;
  bool showTime;

  DateType dateType;
  TxtStile dateStyle;
  Color? dateColor;

  _ClockConfig(
    this.shape,
    this.background,
    this.timeStyle,
    this.timeColor,
    this.showTime,
    this.dateType,
    this.dateStyle,
    this.dateColor,
  );
}

/// background, time, date
enum _Edits { background, time, date }

/// background, time, date
extension _Title on _Edits {
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
  final ListAlignment hAlign;
  final ListAlignment vAlign;

  const AddClock(
    this.config,
    this.appInfo,
    this.lane, {
    super.key,
    required this.hAlign,
    required this.vAlign,
  });

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
          mainAxisAlignment: vAlign.mainAxis,
          crossAxisAlignment: hAlign.crossAxis,
          children: <Widget>[
            Text(
              TimeOfDay.fromDateTime(now).format(context),
              style: config.headlineStyle,
              textAlign: hAlign.textAlign,
            ),
            Text(
              DTConfig.buildDate(context, now, DateType.compact),
              style: config.labelStyle,
              textAlign: hAlign.textAlign,
            ),
          ],
        ),
      ),
    );
  }
}
