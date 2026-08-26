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

class TimerWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final TileState state;
  final LimPos pos;
  final ValueNotifier<double>? rippleProgress;
  final void Function() editReset;

  final List<String> data;
  late final String _tp;
  late final WWGGSize _size;
  late final List<String> _prev;
  late final List<String> _times;

  TimerWidget(
    this.config,
    this.appInfo,
    this.state,
    this.pos,
    this.rippleProgress,
    this.editReset,
    this.data, {
    super.key,
  }) {
    _tp = data[0]; // Not used here; tracked so local updates don't clobber it
    _size = WSConfig.safeLookup(data[1]);

    final List<String> storedPrev = data[2].split(colon);
    _prev = storedPrev.length == 3 ? storedPrev : <String>['00', '00', '00'];

    _times = data.sublist(3);
  }

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  // Define the build data //

  late TileState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

  late final TextEditingController ourCon = TextEditingController(text: widget._prev[0]);
  late final TextEditingController minCon = TextEditingController(text: widget._prev[1]);
  late final TextEditingController secCon = TextEditingController(text: widget._prev[2]);

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
      width: ezTextSize(
            widget.config,
            text: '000',
            style: widget.config.bodyStyle,
            textScaler: MediaQuery.textScalerOf(context),
          ).width +
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
            builder: (_, MenuController controller, __) => WideTile(
              widget.config,
              alignment: widget.pos.subAlign,
              onLongPress: () async => await canToggleMenu(widget.config, menuControl),
              child: (widget._size == WWGGSize.button)
                  ? EzIconButton(
                      widget.config,
                      icon: const Icon(Icons.timer_outlined),
                      tooltip: l10n(widget.config).gStart,
                      onPressed: () async {
                        final int ours = _toInt(ourCon.text);
                        final int mins = _toInt(minCon.text);
                        final int secs = _toInt(secCon.text);

                        ((ours + mins + secs) > 0)
                            ? await setTimer(<int>[ours, mins, secs])
                            : ezSnackBar(
                                widget.config,
                                context: context,
                                message: l10n(widget.config).timBadTime,
                              );
                      },
                      onLongPress: () async => await canToggleMenu(widget.config, controller),
                    )
                  : EzScrollBlocker(EzScrollView(
                      widget.config,
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        if (widget.config.isLefty) ...<Widget>[
                          widget.config.rowMargin,
                          EzIconButton(
                            widget.config,
                            icon: const Icon(Icons.timer_outlined),
                            tooltip: l10n(widget.config).gStart,
                            onPressed: () async {
                              removeOverlay();
                              await setTimer(<int>[
                                _toInt(ourCon.text),
                                _toInt(minCon.text),
                                _toInt(secCon.text),
                              ]);
                            },
                            onLongPress: () async => await canToggleMenu(widget.config, controller),
                          ),
                        ],

                        // Hours
                        _timeField(
                          constraints: numConstraints,
                          tc: ourCon,
                          curr: ourNode,
                          label: l10n(widget.config).timHours,
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
                          label: l10n(widget.config).timMins,
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
                          label: l10n(widget.config).timSecs,
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

                        if (!widget.config.isLefty) ...<Widget>[
                          widget.config.rowMargin,
                          EzIconButton(
                            widget.config,
                            icon: const Icon(Icons.timer_outlined),
                            tooltip: l10n(widget.config).gStart,
                            onPressed: () async {
                              removeOverlay();
                              await setTimer(<int>[
                                _toInt(ourCon.text),
                                _toInt(minCon.text),
                                _toInt(secCon.text),
                              ]);
                            },
                            onLongPress: () async => await canToggleMenu(widget.config, controller),
                          ),
                        ],
                      ],
                    )),
            ),
            menuChildren: _menuChildren(
              widget.config,
              appInfo: widget.appInfo,
              context: context,
              state: state,
              editReset: widget.editReset,
              numLanes: numLanes,
              pos: widget.pos,
              initConfig: _TimerConfig(
                tp: widget._tp,
                size: widget._size,
                constraints: numConstraints,
                auto: <String>[
                  _validateTime(ourCon.text),
                  _validateTime(minCon.text),
                  _validateTime(secCon.text),
                ].join(colon),
                quick: widget._times,
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
              editReset: widget.editReset,
              numLanes: numLanes,
              pos: widget.pos,
              initConfig: _TimerConfig(
                tp: widget._tp,
                size: widget._size,
                constraints: numConstraints,
                auto: <String>[
                  _validateTime(ourCon.text),
                  _validateTime(minCon.text),
                  _validateTime(secCon.text),
                ].join(colon),
                quick: widget._times,
              ),
            ),
            child: EzIconButton(
              widget.config,
              icon: const Icon(Icons.timer_outlined),
              tooltip: l10n(widget.config).timTitle,
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
  required void Function() editReset,
  required int numLanes,
  required LimPos pos,
  required _TimerConfig initConfig,
}) =>
    <Widget>[
      // Quick times
      ...initConfig.quick.map((String time) => EzMenuButton(
            config,
            label: time,
            onPressed: () async {
              final List<String> parts = time.split(colon);
              await setTimer(parts.map((String p) => _toInt(p)).toList());
            },
          )),

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
      reposition(config, appInfo, pos, stateCheck: editReset),

      // Move
      if (state == TileState.groupEdit && numLanes > 1) ...<Widget>[
        moveDownLane(config, appInfo, pos, numLanes: numLanes),
        moveUpLane(config, appInfo, pos, numLanes: numLanes),
      ],

      // Remove
      removeItem(config, appInfo, pos),
    ];

Widget _timeField({
  required BoxConstraints constraints,
  required TextEditingController tc,
  required FocusNode curr,
  required String label,
  void Function(String)? onChanged,
  void Function()? onTap,
  void Function()? onTapOutside,
  required void Function() onSubmit,
  bool last = false,
}) =>
    EzTextField(
      controller: tc,
      constraints: constraints,
      errorConstraints: BoxConstraints.tightFor(width: constraints.maxWidth * 2),
      focusNode: curr,
      hintText: '00',
      label: label,
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
  final WWGGSize size;

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
        type: WWGG.timer,
        size: size,
        editNew: () => _openEdits(
          config,
          appInfo: appInfo,
          pContext: pContext,
          initConfig: _TimerConfig(
            tp: nullTPS,
            size: size,
            constraints: BoxConstraints.tightFor(
              height: appIconSize(config),
              width: ezTextSize(
                    config,
                    text: '000',
                    style: config.bodyStyle,
                    textScaler: MediaQuery.textScalerOf(pContext),
                  ).width +
                  (2 * config.padding),
            ),
            auto: _noTime,
            quick: _defaultQuick,
          ),
          lane: lane,
          index: appInfo.homeLane(config, lane).length - 1,
        ),
        lane: lane,
      );

  @override
  Widget build(BuildContext context) {
    late final Widget fauxTimerField = ExcludeSemantics(
      child: EzTextField(
        constraints: BoxConstraints(
          maxHeight: appIconSize(config),
          maxWidth: ezTextSize(
                config,
                text: '00',
                style: config.bodyStyle,
                textScaler: MediaQuery.textScalerOf(context),
              ).width +
              config.padding,
        ),
        hintText: '00',
        onTap: onTap,
        readOnly: true,
        validator: null,
      ),
    );

    return (size == WWGGSize.button)
        ? EzIconButton(
            config,
            onPressed: onTap,
            tooltip: l10n(config).gAdd,
            icon: const Icon(Icons.timer),
          )
        : GestureDetector(
            onTap: onTap,
            child: MergeSemantics(
              child: EzScrollView(
                config,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  if (config.isLefty) ...<Widget>[
                    config.rowMargin,
                    EzIconButton(
                      config,
                      onPressed: onTap,
                      tooltip: l10n(config).gAdd,
                      icon: const Icon(Icons.timer),
                    ),
                  ],
                  fauxTimerField,
                  config.rowMargin,
                  fauxTimerField,
                  config.rowMargin,
                  fauxTimerField,
                  if (!config.isLefty) ...<Widget>[
                    config.rowMargin,
                    EzIconButton(
                      config,
                      onPressed: onTap,
                      tooltip: l10n(config).gAdd,
                      icon: const Icon(Icons.timer),
                    ),
                  ],
                ],
              ),
            ),
          );
  }
}

const String _noTime = '00:00:00';
const List<String> _defaultQuick = <String>['00:10:00', '00:30:00', '01:00:00'];

String defaultTimerEntry(WWGGSize size) => _timerEntry(
      tp: nullTPS,
      size: size,
      auto: _noTime,
      quick: _defaultQuick,
    );

String _timerEntry({
  required String tp,
  required WWGGSize size,
  required String auto,
  required Iterable<String> quick,
}) =>
    <String>[
      tp,
      size.value,
      auto,
      ...quick,
    ].join(configSplit);

//* Edit Widget *//

class _TimerConfig {
  final String tp;
  final WWGGSize size;
  final BoxConstraints constraints;
  final String auto;
  final List<String> quick;

  _TimerConfig({
    required this.tp,
    required this.size,
    required this.constraints,
    required this.auto,
    required this.quick,
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
  final EdgeInsets wrapPadding = EzInsets.wrap(config.spacing);

  WWGGSize size = initConfig.size;
  double bottomSpace = config.spacing * 2;

  final List<String> quick = List<String>.from(initConfig.quick);

  final TextEditingController ourCon = TextEditingController();
  final TextEditingController minCon = TextEditingController();
  final TextEditingController secCon = TextEditingController();

  final FocusNode ourNode = FocusNode();
  final FocusNode minNode = FocusNode();
  final FocusNode secNode = FocusNode();

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

          EzFlipFlop(
            config,
            onLabel: l10n(config).gTile,
            offLabel: l10n(config).gButton,
            init: initConfig.size == WWGGSize.tile,
            onChanged: (bool tile) => setModal(() => size = tile ? WWGGSize.tile : WWGGSize.button),
          ),
          config.spacer,

          // Quick times //

          // Add
          EzScrollView(
            config,
            scrollDirection: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (config.isLefty) ...<Widget>[
                EzIconButton(
                  config,
                  icon: EzIcon(config, Icons.add),
                  tooltip: l10n(config).gAdd,
                  onPressed: () {
                    quick.add(<String>[
                      _validateTime(ourCon.text),
                      _validateTime(minCon.text),
                      _validateTime(secCon.text),
                    ].join(colon));
                    quick.sort();
                    setModal(() {});
                  },
                ),
                config.rowMargin,
              ],

              // Hours
              _timeField(
                constraints: initConfig.constraints,
                tc: ourCon,
                curr: ourNode,
                label: l10n(config).timHours,
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
                constraints: initConfig.constraints,
                tc: minCon,
                curr: minNode,
                label: l10n(config).timMins,
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
                constraints: initConfig.constraints,
                tc: secCon,
                curr: secNode,
                label: l10n(config).timSecs,
                onTap: () => grow(),
                onTapOutside: shrink,
                onSubmit: () {
                  secNode.unfocus();
                  shrink();
                },
                last: true,
              ),

              if (!config.isLefty) ...<Widget>[
                config.rowMargin,
                EzIconButton(
                  config,
                  icon: EzIcon(config, Icons.add),
                  tooltip: l10n(config).gAdd,
                  onPressed: () {
                    quick.add(<String>[
                      _validateTime(ourCon.text),
                      _validateTime(minCon.text),
                      _validateTime(secCon.text),
                    ].join(colon));
                    quick.sort();
                    setModal(() {});
                  },
                ),
              ],
            ],
          ),
          if (quick.isNotEmpty)
            EzTitledDivider(
              config,
              title: Text(
                l10n(config).timQuick,
                textAlign: TextAlign.center,
                style: config.labelStyle,
              ),
              height: config.spacing * 2,
            ),

          // List
          EzWrap(
            children: quick
                .map((String time) => Padding(
                      padding: wrapPadding,
                      child: EzElevatedButton(
                        config,
                        key: ValueKey<String>(time),
                        text: time,
                        onPressed: () {
                          quick.remove(time);
                          quick.sort();
                          setModal(() {});
                        },
                      ),
                    ))
                .toList(),
          ),
          EzSpacer(bottomSpace),
        ]);
      },
    ),
  );

  await appInfo.updateWidget(
    config,
    WWGG.timer,
    _timerEntry(
      tp: initConfig.tp,
      size: size,
      auto: <String>[
        _validateTime(ourCon.text),
        _validateTime(minCon.text),
        _validateTime(secCon.text),
      ].join(colon),
      quick: quick,
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
