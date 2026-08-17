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

class ClockWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final TileState state;
  final ValueNotifier<double>? rippleProgress;
  final LimPos pos;

  final List<String> data;
  late final String _tp;
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
    this.state,
    this.rippleProgress,
    this.pos,
    this.data, {
    super.key,
  }) {
    _tp = data[0]; // Not used here; tracked so local updates don't clobber it
    _shape = EBSConfig.safeLookup(data[1]);

    late final int? bCV = int.tryParse(data[2]);
    _background = bCV == null ? null : Color(bCV);

    _showTime = bool.tryParse(data[3]) ?? true;
    _timeStyle = TSConfig.lookup(data[4]) ?? TxtStile.headline;

    late final int? tCV = int.tryParse(data[5]);
    _timeColor = tCV == null ? null : Color(tCV);

    _dateType = DTConfig.safeLookup(data[6]);
    _dateStyle = TSConfig.lookup(data[7]) ?? TxtStile.label;

    late final int? dCV = int.tryParse(data[8]);
    _dateColor = dCV == null ? null : Color(dCV);
  }

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  // Define the build data //

  late TileState state = widget.state;
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
        TileState.standard => MenuAnchor(
            builder: (_, MenuController controller, __) => GestureDetector(
              onLongPress: () async => await canToggleMenu(widget.config, controller),
              child: EzTextBackground(
                widget.config,
                shape: widget._shape,
                backgroundColor: widget._background,
                text: EzCol(
                  mainAxisAlignment: widget.pos.vAlign.mainAxis,
                  crossAxisAlignment: widget.pos.hAlign.crossAxis,
                  children: <Widget>[
                    if (widget._showTime)
                      Text(
                        TimeOfDay.fromDateTime(now).format(context),
                        style: widget._timeStyle
                            .style(widget.config)
                            ?.copyWith(color: widget._timeColor),
                        textAlign: widget.pos.hAlign.textAlign,
                      ),
                    if (widget._dateType != DateType.none)
                      Text(
                        DTConfig.buildDate(context, now, widget._dateType),
                        style: widget._dateStyle
                            .style(widget.config)
                            ?.copyWith(color: widget._dateColor),
                        textAlign: widget.pos.hAlign.textAlign,
                      ),
                  ],
                ),
              ),
            ),
            menuChildren: _menuChildren(
              widget.config,
              appInfo: widget.appInfo,
              context: context,
              state: state,
              numLanes: numLanes,
              pos: widget.pos,
              initConfig: _ClockConfig(
                tp: widget._tp,
                hAlign: widget.pos.hAlign,
                vAlign: widget.pos.vAlign,
                shape: widget._shape,
                background: widget._background,
                timeStyle: widget._timeStyle,
                timeColor: widget._timeColor,
                showTime: widget._showTime,
                dateType: widget._dateType,
                dateStyle: widget._dateStyle,
                dateColor: widget._dateColor,
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
              numLanes: numLanes,
              pos: widget.pos,
              initConfig: _ClockConfig(
                tp: widget._tp,
                hAlign: widget.pos.hAlign,
                vAlign: widget.pos.vAlign,
                shape: widget._shape,
                background: widget._background,
                timeStyle: widget._timeStyle,
                timeColor: widget._timeColor,
                showTime: widget._showTime,
                dateType: widget._dateType,
                dateStyle: widget._dateStyle,
                dateColor: widget._dateColor,
              ),
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

List<Widget> _menuChildren(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext context,
  required TileState state,
  required int numLanes,
  required LimPos pos,
  required _ClockConfig initConfig,
}) =>
    <Widget>[
      // Edit
      _EditClock(
        config,
        appInfo,
        pContext: context,
        initConfig: initConfig,
        lane: pos.lane,
        index: pos.index,
      ),

      // Dupe
      EzMenuButton(
        config,
        label: l10n(config).gDupe,
        icon: EzIcon(config, Icons.copy),
        onPressed: () => appInfo.dupeItem(
          config,
          editNew: () async {
            if (!ezRootIsMounted) return;
            await _openEdits(
              config,
              appInfo: appInfo,
              pContext: ezRootContext,
              initConfig: initConfig,
              lane: pos.lane,
              index: pos.index,
            );
          },
          lane: pos.lane,
          index: pos.index,
        ),
      ),

      // Reposition
      reposition(config, appInfo, pos, context: context),

      // Move
      if (state == TileState.groupEdit && numLanes > 1) ...<Widget>[
        moveDownLane(config, appInfo, pos, numLanes: numLanes),
        moveUpLane(config, appInfo, pos, numLanes: numLanes),
      ],

      // Remove
      removeItem(config, appInfo, pos),
    ];

//* Add Widget *//

class AddClock extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext pContext;
  final int lane;
  final ListAlignment hAlign;
  final ListAlignment vAlign;

  const AddClock(
    this.config, {
    super.key,
    required this.appInfo,
    required this.pContext,
    required this.lane,
    required this.hAlign,
    required this.vAlign,
  });

  void onTap() => appInfo.addWidget(
        config,
        type: WWGG.clock,
        editNew: () => _openEdits(
          config,
          appInfo: appInfo,
          pContext: pContext,
          initConfig: _ClockConfig(
            tp: nullTPS,
            hAlign: hAlign,
            vAlign: vAlign,
            shape: EzButtonShape.roundRect,
            background: null,
            timeStyle: TxtStile.headline,
            timeColor: null,
            showTime: true,
            dateType: DateType.compact,
            dateStyle: TxtStile.label,
            dateColor: null,
          ),
          lane: lane,
          index: appInfo.homeLane(config, lane).length - 1,
        ),
        lane: lane,
      );

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    return GestureDetector(
      onTap: onTap,
      child: EzTextBackground(
        config,
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

String defaultClockEntry() => _clockEntry(
      tp: nullTPS,
      shape: EzButtonShape.roundRect,
      backColor: null,
      showTime: true,
      timeStyle: TxtStile.headline,
      timeColor: null,
      dateType: DateType.compact,
      dateStyle: TxtStile.label,
      dateColor: null,
    );

String _clockEntry({
  required String tp,
  required EzButtonShape shape,
  required Color? backColor,
  required bool showTime,
  required TxtStile timeStyle,
  required Color? timeColor,
  required DateType dateType,
  required TxtStile dateStyle,
  required Color? dateColor,
}) =>
    <String>[
      tp,
      shape.value,
      backColor == null ? esSystem : backColor.toARGB32().toString(),
      showTime.toString(),
      timeStyle.value,
      timeColor == null ? esSystem : timeColor.toARGB32().toString(),
      dateType.value,
      dateStyle.value,
      dateColor == null ? esSystem : dateColor.toARGB32().toString(),
    ].join(configSplit);

//* Edit Widget *//

class _ClockConfig {
  final String tp;
  final ListAlignment hAlign;
  final ListAlignment vAlign;

  final EzButtonShape shape;
  final Color? background;

  final TxtStile timeStyle;
  final Color? timeColor;
  final bool showTime;

  final DateType dateType;
  final TxtStile dateStyle;
  final Color? dateColor;

  const _ClockConfig({
    required this.tp,
    required this.hAlign,
    required this.vAlign,
    required this.shape,
    required this.background,
    required this.timeStyle,
    required this.timeColor,
    required this.showTime,
    required this.dateType,
    required this.dateStyle,
    required this.dateColor,
  });
}

/// background, time, date
enum _Edits { background, time, date }

/// background, time, date
extension _Title on _Edits {
  String name(EzCP config) => switch (this) {
        _Edits.background => l10n(config).clkBackground,
        _Edits.time => l10n(config).clkTime,
        _Edits.date => l10n(config).clkDate,
      };
}

Future<void> _openEdits(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext pContext,
  required _ClockConfig initConfig,
  required int lane,
  required int index,
}) async {
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
    context: pContext,
    builder: (_) => StatefulBuilder(
      builder: (BuildContext mCon, StateSetter setModal) {
        void nav(_Edits choice) {
          delta = choice.index - curr.index;
          setModal(() => curr = choice);
        }

        Widget backgroundSettings() => EzScrollView(config, children: <Widget>[
              // Shape
              Text(
                l10n(config).clkBackgroundShape,
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
                          child: EzCol(
                            children: <Widget>[
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
                            ],
                          ),
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
                    context: pContext,
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
                label: l10n(config).clkBackgroundColor,
                textAlign: TextAlign.center,
              ),
            ]);

        Widget timeSettings() => EzScrollView(config, children: <Widget>[
              // Time style
              EzDropdownMenu<TxtStile>(
                config,
                label: l10n(config).clkTimeStyle,
                labelStyle: timeStyle.style(config),
                enabled: showTime,
                enableSearch: false,
                initialSelection: timeStyle,
                widthEntry: TxtStile.display.value,
                dropdownMenuEntries: TxtStile.values
                    .map((TxtStile ts) =>
                        DropdownMenuEntry<TxtStile>(value: ts, label: ezCamelToTitle(ts.value)))
                    .toList(),
                menuStyle: timeStyle.style(config),
                onSelected: (TxtStile? choice) {
                  if (choice == null) return;
                  setModal(() => timeStyle = choice);
                },
              ),
              config.spacer,

              // Time color
              EzElevatedIconButton(
                config,
                enabled: showTime,
                onPressed: () async {
                  Color curr = timeColor ?? config.colors.onSurface;

                  await ezColorPicker(
                    config,
                    context: pContext,
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
                label: l10n(config).clkTimeColor,
                textAlign: TextAlign.center,
              ),
              config.spacer,

              // Time on/off
              EzSwitchPair(
                key: ValueKey<bool>(showTime),
                config,
                value: showTime,
                text: l10n(config).clkTimeBool,
                onChanged: (bool? choice) {
                  if (choice == null) return;
                  setModal(() => showTime = choice);
                },
              ),
            ]);

        Widget dateSettings() => EzScrollView(config, children: <Widget>[
              // Date type
              EzDropdownMenu<DateType>(
                config,
                label: l10n(config).clkDateType,
                enableSearch: false,
                initialSelection: dateType,
                widthEntry: DateType.compact.value,
                dropdownMenuEntries: DateType.values
                    .map((DateType dt) =>
                        DropdownMenuEntry<DateType>(value: dt, label: ezCamelToTitle(dt.value)))
                    .toList(),
                onSelected: (DateType? choice) {
                  if (choice == null) return;
                  setModal(() => dateType = choice);
                },
              ),
              config.spacer,

              // Date style
              EzDropdownMenu<TxtStile>(
                config,
                label: l10n(config).clkDateStyle,
                labelStyle: dateStyle.style(config),
                enabled: dateType != DateType.none,
                enableSearch: false,
                initialSelection: dateStyle,
                widthEntry: TxtStile.display.value,
                dropdownMenuEntries: TxtStile.values
                    .map((TxtStile ts) =>
                        DropdownMenuEntry<TxtStile>(value: ts, label: ezCamelToTitle(ts.value)))
                    .toList(),
                menuStyle: dateStyle.style(config),
                onSelected: (TxtStile? choice) {
                  if (choice == null) return;
                  setModal(() => dateStyle = choice);
                },
              ),
              config.spacer,

              // Date color
              EzElevatedIconButton(
                config,
                enabled: dateType != DateType.none,
                onPressed: () async {
                  Color curr = dateColor ?? config.colors.onSurface;

                  await ezColorPicker(
                    config,
                    context: pContext,
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
                label: l10n(config).clkDateColor,
                textAlign: TextAlign.center,
              ),
            ]);

        return EzCol(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            // Switcher
            SegmentedButton<_Edits>(
              segments: _Edits.values
                  .map((_Edits et) => ButtonSegment<_Edits>(
                        value: et,
                        label: Text(et.name(config), textAlign: TextAlign.center),
                      ))
                  .toList(),
              selected: <_Edits>{curr},
              showSelectedIcon: false,
              onSelectionChanged: (Set<_Edits> selected) => nav(selected.first),
            ),
            config.spacer,

            // Preview
            EzTextBackground(
              config,
              shape: shape,
              backgroundColor: background,
              text: EzCol(
                mainAxisAlignment: initConfig.vAlign.mainAxis,
                crossAxisAlignment: initConfig.hAlign.crossAxis,
                children: <Widget>[
                  if (showTime)
                    Text(
                      TimeOfDay.fromDateTime(DateTime.now()).format(mCon),
                      style: timeStyle.style(config)?.copyWith(color: timeColor),
                      textAlign: initConfig.hAlign.textAlign,
                    ),
                  if (dateType != DateType.none)
                    Text(
                      DTConfig.buildDate(mCon, DateTime.now(), dateType),
                      style: dateStyle.style(config)?.copyWith(color: dateColor),
                      textAlign: initConfig.hAlign.textAlign,
                    ),
                ],
              ),
            ),
            config.divider,

            // Settings
            Expanded(
              child: EzSwipeDetector(
                rtl: () => (curr.index < 2) ? nav(_Edits.values[curr.index + 1]) : doNothing(),
                ltr: () => (curr.index > 0) ? nav(_Edits.values[curr.index - 1]) : doNothing(),
                child: EzFauxCarousel(
                  config,
                  position: curr.index,
                  delta: delta,
                  child: InkWell(
                    child: Container(
                      alignment: Alignment.topCenter,
                      constraints: BoxConstraints.tight(Size.infinite),
                      child: switch (curr) {
                        _Edits.background => backgroundSettings(),
                        _Edits.time => timeSettings(),
                        _Edits.date => dateSettings(),
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  await appInfo.updateWidget(
    config,
    WWGG.clock,
    _clockEntry(
      tp: initConfig.tp,
      shape: shape,
      backColor: background,
      showTime: showTime,
      timeStyle: timeStyle,
      timeColor: timeColor,
      dateType: dateType,
      dateStyle: dateStyle,
      dateColor: dateColor,
    ),
    lane: lane,
    index: index,
  );
}

class _EditClock extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext pContext;
  final _ClockConfig initConfig;
  final int lane;
  final int index;

  const _EditClock(
    this.config,
    this.appInfo, {
    required this.pContext,
    required this.initConfig,
    required this.lane,
    required this.index,
  });

  @override
  Widget build(_) => EzMenuButton(
        config,
        label: l10n(config).gEdit,
        icon: EzIcon(config, Icons.edit),
        onPressed: () => _openEdits(
          config,
          appInfo: appInfo,
          pContext: pContext,
          initConfig: initConfig,
          lane: lane,
          index: index,
        ),
      );
}
