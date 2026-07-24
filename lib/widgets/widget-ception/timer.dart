/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:open_ui/open_ui.dart';

//* Core Widget *//

class TimerWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final LimPos pos;
  final TileState state;
  final ValueNotifier<double>? rippleProgress;

  late final WidgetSize _size;
  late final List<String> _times;

  TimerWidget(this.config, this.appInfo, this.pos, this.state, this.rippleProgress, {super.key}) {
    final List<String> data = appInfo
        .homeItem(config, lane: pos.lane, index: pos.index)
        .split(widgetSplit)[1]
        .split(configSplit);

    _size = WSConfig.safeLookup(data[0]);

    final List<String> storedTs = data[1].split(':');
    _times = storedTs.length == 3 ? storedTs : <String>['00', '00', '00'];
  }

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  // Define the build data //

  late TileState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

  late final TextEditingController ourCon = TextEditingController(text: widget._times[0]);
  late final TextEditingController minCon = TextEditingController(text: widget._times[1]);
  late final TextEditingController secCon = TextEditingController(text: widget._times[2]);

  late final FocusNode ourNode = FocusNode();
  late final FocusNode minNode = FocusNode();
  late final FocusNode secNode = FocusNode();

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

  void showOverlay(TextEditingController controller) {
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
                controller.text,
                style: widget.config.bodyStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
    ezRootOverlay?.insert(overlayEntry!);
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
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final int numLanes = widget.appInfo.numLanes(widget.config);

    late final BoxConstraints numConstraints = BoxConstraints.tightFor(
      height: appIconSize(widget.config),
      width: ezTextSize('000', context: context, style: widget.config.bodyStyle).width +
          (2 * widget.config.padding),
    );

    void onChanged(String value, TextEditingController tc) => value.isEmpty
        ? removeOverlay()
        : ((overlayEntry == null) ? showOverlay(tc) : overlayEntry!.markNeedsBuild());

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceFade: true,
      forceType: EzTransitionType.none,
      child: switch (state) {
        TileState.standard => MenuAnchor(
            builder: (_, MenuController controller, __) => (widget._size == WidgetSize.button)
                ? EzIconButton(
                    widget.config,
                    icon: const Icon(Icons.timer_outlined),
                    onPressed: () async {
                      final int ours = _toInt(ourCon.text);
                      final int mins = _toInt(minCon.text);
                      final int secs = _toInt(secCon.text);

                      ((ours + mins + secs) > 0)
                          ? await setTimer(<int>[ours, mins, secs])
                          : ezSnackBar(widget.config, context: context, message: 'Invalid time');
                    },
                    onLongPress: () => canToggleMenu(widget.config, controller),
                  )
                : EzRow(
                    widget.config,
                    children: <Widget>[
                      // Hours
                      _timeField(
                        constraints: numConstraints,
                        tc: ourCon,
                        curr: ourNode,
                        onChanged: (String s) => onChanged(s, ourCon),
                        onSubmit: () {
                          removeOverlay();
                          minNode.requestFocus();
                          minCon.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: minCon.text.length,
                          );
                        },
                      ),
                      widget.config.rowMargin,

                      // Minutes
                      _timeField(
                        constraints: numConstraints,
                        tc: minCon,
                        curr: minNode,
                        onChanged: (String s) => onChanged(s, minCon),
                        onSubmit: () {
                          removeOverlay();
                          secNode.requestFocus();
                          secCon.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: secCon.text.length,
                          );
                        },
                      ),
                      widget.config.rowMargin,

                      // Seconds
                      _timeField(
                        constraints: numConstraints,
                        tc: secCon,
                        curr: secNode,
                        onChanged: (String s) => onChanged(s, secCon),
                        onSubmit: () async {
                          removeOverlay();
                          await setTimer(<int>[
                            _toInt(ourCon.text),
                            _toInt(minCon.text),
                            _toInt(secCon.text),
                          ]);
                        },
                        last: true,
                      ),
                      widget.config.rowMargin,

                      EzIconButton(
                        widget.config,
                        icon: const Icon(Icons.timer_outlined),
                        onPressed: () async {
                          removeOverlay();
                          await setTimer(<int>[
                            _toInt(ourCon.text),
                            _toInt(minCon.text),
                            _toInt(secCon.text),
                          ]);
                        },
                        onLongPress: () => canToggleMenu(widget.config, controller),
                      ),
                    ],
                  ),
            menuChildren: _menuChildren(
              widget.config,
              appInfo: widget.appInfo,
              context: context,
              state: state,
              numLanes: numLanes,
              pos: widget.pos,
              initConfig: _TimerConfig(
                size: widget._size,
                fieldCon: numConstraints,
                ours: _validateTime(ourCon.text),
                mins: _validateTime(minCon.text),
                secs: _validateTime(secCon.text),
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
              initConfig: _TimerConfig(
                size: widget._size,
                fieldCon: numConstraints,
                ours: _validateTime(ourCon.text),
                mins: _validateTime(minCon.text),
                secs: _validateTime(secCon.text),
              ),
            ),
            child: EzIconButton(
              widget.config,
              icon: const Icon(Icons.timer_outlined),
              onPressed: () => toggleMenu(menuControl),
            ),
          ),
      },
    );
  }

  @override
  void dispose() {
    ourNode.dispose();
    minNode.dispose();
    secNode.dispose();

    removeOverlay();
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
  required _TimerConfig initConfig,
}) =>
    <Widget>[
      // Edit
      _EditTimer(
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
        label: 'Duplicate',
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

      // Move
      if (state == TileState.groupEdit && numLanes > 1) ...<Widget>[
        moveDownLane(config, appInfo, numLanes: numLanes, lane: pos.lane, index: pos.index),
        moveUpLane(config, appInfo, numLanes: numLanes, lane: pos.lane, index: pos.index),
      ],

      // Remove
      removeItem(config, appInfo, lane: pos.lane, index: pos.index),
    ];

Widget _timeField({
  required BoxConstraints constraints,
  required TextEditingController tc,
  required FocusNode curr,
  void Function(String)? onChanged,
  void Function()? onTap,
  void Function()? onTapOutside,
  required void Function() onSubmit,
  bool last = false,
}) =>
    EzScrollBlocker(
      EzTextField(
        controller: tc,
        constraints: constraints,
        errorConstraints: BoxConstraints.tightFor(width: constraints.maxWidth * 2),
        focusNode: curr,
        hintText: '00',
        keyboardType: TextInputType.number,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        onTap: () {
          tc.clear();
          onTap?.call();
        },
        onTapOutside: (_) {
          if (tc.text.isEmpty) tc.text = '00';
          onTapOutside?.call();
        },
        onChanged: onChanged,
        onEditingComplete: () {
          if (tc.text.isEmpty) tc.text = '00';
        },
        onFieldSubmitted: (String value) {
          if (value.isEmpty) tc.text = '00';
          onSubmit.call();
        },
        validator: (String? value) {
          const String failure = '0-99';

          if (value == null) return failure;
          final int parsed = int.tryParse(value) ?? -1;

          return (parsed > 99 || parsed < 0) ? failure : null;
        },
      ),
    );

String _validateTime(String time) {
  final int? value = int.tryParse(time);
  return (value == null) ? '00' : ((value > 99) ? '99' : time);
}

int _toInt(String time) {
  final int? value = int.tryParse(time);
  return (value == null) ? 0 : ((value > 99) ? 99 : value);
}

//* Add Widget *//

class AddTimer extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext pContext;
  final int lane;
  final WidgetSize size;

  const AddTimer(
    this.config, {
    super.key,
    required this.appInfo,
    required this.pContext,
    required this.lane,
    required this.size,
  });

  void onTap() => appInfo.addWidget(
        config,
        type: WidWidGetGet.timer,
        editNew: () => _openEdits(
          config,
          appInfo: appInfo,
          pContext: pContext,
          initConfig: _TimerConfig(
            size: size,
            fieldCon: BoxConstraints.tightFor(
              height: appIconSize(config),
              width: ezTextSize('000', context: pContext, style: config.bodyStyle).width +
                  (2 * config.padding),
            ),
            ours: '00',
            mins: '00',
            secs: '00',
          ),
          lane: lane,
          index: appInfo.homeLane(config, lane).length - 1,
        ),
        lane: lane,
      );

  @override
  Widget build(BuildContext context) {
    late final Widget fauxTimerField = EzTextField(
      constraints: BoxConstraints(
        maxHeight: appIconSize(config),
        maxWidth:
            ezTextSize('00', context: context, style: config.bodyStyle).width + config.padding,
      ),
      hintText: '00',
      onTap: onTap,
      readOnly: true,
      validator: null,
    );

    return (size == WidgetSize.button)
        ? EzIconButton(config, onPressed: onTap, icon: const Icon(Icons.timer))
        : GestureDetector(
            onTap: onTap,
            child: EzRow(
              config,
              reverseHands: false,
              children: <Widget>[
                fauxTimerField,
                config.rowMargin,
                fauxTimerField,
                config.rowMargin,
                fauxTimerField,
                config.rowMargin,
                EzIconButton(config, onPressed: onTap, icon: const Icon(Icons.timer)),
              ],
            ),
          );
  }
}

String defaultTimerEntry() => _timerEntry(WidgetSize.tile, '00:00:00');

String _timerEntry(WidgetSize size, String autoTime) =>
    <String>[size.value, autoTime].join(configSplit);

//* Edit Widget *//

class _TimerConfig {
  final WidgetSize size;
  final BoxConstraints fieldCon;
  final String ours;
  final String mins;
  final String secs;

  _TimerConfig({
    required this.size,
    required this.fieldCon,
    required this.ours,
    required this.mins,
    required this.secs,
  });
}

Future<void> _openEdits(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext pContext,
  required _TimerConfig initConfig,
  required int lane,
  required int index,
}) async {
  final TextEditingController ourCon = TextEditingController(text: initConfig.ours);
  final TextEditingController minCon = TextEditingController(text: initConfig.mins);
  final TextEditingController secCon = TextEditingController(text: initConfig.secs);

  final FocusNode ourNode = FocusNode();
  final FocusNode minNode = FocusNode();
  final FocusNode secNode = FocusNode();

  WidgetSize size = initConfig.size;
  double bottomSpace = config.spacing * 2;

  await ezModal(
    config,
    context: pContext,
    builder: (_) => StatefulBuilder(
      builder: (_, StateSetter setModal) {
        Future<void> grow() async {
          // Wait a bit for the keyboard to open
          await Future<void>.delayed(keyTime);
          setModal(
              () => bottomSpace = (config.spacing * 2) + MediaQuery.of(pContext).viewInsets.bottom);
        }

        void shrink() => setModal(() => bottomSpace = config.spacing * 2);

        return ezModalScroll(config, children: <Widget>[
          // Size //

          SegmentedButton<WidgetSize>(
            segments: const <ButtonSegment<WidgetSize>>[
              ButtonSegment<WidgetSize>(
                value: WidgetSize.button,
                label: Text('Button', textAlign: TextAlign.center),
              ),
              ButtonSegment<WidgetSize>(
                value: WidgetSize.tile,
                label: Text('Tile', textAlign: TextAlign.center),
              ),
            ],
            selected: <WidgetSize>{size},
            showSelectedIcon: false,
            onSelectionChanged: (Set<WidgetSize> selected) => setModal(() => size = selected.first),
          ),
          config.spacer,

          // Default time //

          EzRow(
            config,
            reverseHands: false,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Hours
              _timeField(
                constraints: initConfig.fieldCon,
                tc: ourCon,
                curr: ourNode,
                onTap: () => grow(),
                onTapOutside: shrink,
                onSubmit: () {
                  minNode.requestFocus();
                  minCon.selection = TextSelection(baseOffset: 0, extentOffset: minCon.text.length);
                },
              ),
              config.rowMargin,

              // Minutes
              _timeField(
                constraints: initConfig.fieldCon,
                tc: minCon,
                curr: minNode,
                onTap: () => grow(),
                onTapOutside: shrink,
                onSubmit: () {
                  secNode.requestFocus();
                  secCon.selection = TextSelection(baseOffset: 0, extentOffset: secCon.text.length);
                },
              ),
              config.rowMargin,

              // Seconds
              _timeField(
                constraints: initConfig.fieldCon,
                tc: secCon,
                curr: secNode,
                onTap: () => grow(),
                onTapOutside: shrink,
                onSubmit: () {
                  secNode.unfocus();
                  shrink();
                },
                last: true,
              ),
            ],
          ),
          EzSpacer(bottomSpace),
        ]);
      },
    ),
  );

  await appInfo.updateWidget(
    config,
    WidWidGetGet.timer,
    _timerEntry(
      size,
      <String>[
        _validateTime(ourCon.text),
        _validateTime(minCon.text),
        _validateTime(secCon.text),
      ].join(':'),
    ),
    lane: lane,
    index: index,
  );
}

class _EditTimer extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext pContext;
  final _TimerConfig initConfig;
  final int lane;
  final int index;

  const _EditTimer(
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
        label: 'Edit',
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
