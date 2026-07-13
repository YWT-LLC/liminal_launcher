/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class TimerWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final LimPos pos;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final WidgetSize _size;
  late final List<String> _times;

  TimerWidget(
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

    final List<String> storedTs = data[1].split(':');
    _times = storedTs.length == 3 ? storedTs : <String>['00', '00', '00'];
  }

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  // Define the build data //

  late AppState state = widget.state;
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
    ezRootNav.currentState?.overlay?.insert(overlayEntry!);
  }

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  Future<bool?> setAutoDialog(BoxConstraints constraints) => showDialog(
        context: context,
        builder: (BuildContext mCon) => EzAlertDialog(
          widget.config,
          content: Padding(
            padding: EdgeInsets.only(top: widget.config.marginVal),
            child: EzRow(
              widget.config,
              reverseHands: false,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Hours
                timeField(
                  constraints,
                  ourCon,
                  ourNode,
                  () {
                    minNode.requestFocus();
                    minCon.selection =
                        TextSelection(baseOffset: 0, extentOffset: minCon.text.length);
                  },
                  useOverlay: false,
                ),
                widget.config.rowMargin,

                // Minutes
                timeField(
                  constraints,
                  minCon,
                  minNode,
                  () {
                    secNode.requestFocus();
                    secCon.selection =
                        TextSelection(baseOffset: 0, extentOffset: secCon.text.length);
                  },
                  useOverlay: false,
                ),
                widget.config.rowMargin,

                // Seconds
                timeField(
                  constraints,
                  secCon,
                  secNode,
                  () => secNode.unfocus(),
                  last: true,
                  useOverlay: false,
                ),
              ],
            ),
          ),
          actions: ezActionPair(
            widget.config,
            onConfirm: () => Navigator.of(mCon).pop(true),
            confirmMsg: widget.config.ezL10n.gApply,
            onDeny: () => Navigator.of(mCon).pop(false),
            denyMsg: widget.config.ezL10n.gCancel,
          ),
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

  Widget timeField(
    BoxConstraints constraints,
    TextEditingController controller,
    FocusNode curr,
    void Function() onSubmit, {
    bool last = false,
    bool useOverlay = true,
  }) =>
      EzScrollBlocker(EzTextField(
        controller: controller,
        constraints: constraints,
        errorConstraints: BoxConstraints.tightFor(width: constraints.maxWidth * 2),
        focusNode: curr,
        hintText: '00',
        keyboardType: TextInputType.number,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        onTap: controller.clear,
        onTapOutside: (_) {
          if (controller.text.isEmpty) controller.text = '00';
        },
        onChanged: (String value) => useOverlay
            ? ((value.isEmpty)
                ? removeOverlay()
                : ((overlayEntry == null)
                    ? showOverlay(controller)
                    : overlayEntry!.markNeedsBuild()))
            : doNothing(),
        onEditingComplete: () {
          if (controller.text.isEmpty) controller.text = '00';
        },
        onFieldSubmitted: (String value) {
          if (value.isEmpty) controller.text = '00';
          onSubmit.call();
        },
        validator: (String? value) {
          const String failure = '0-99';

          if (value == null) return failure;
          final int parsed = int.tryParse(value) ?? -1;

          return (parsed > 99 || parsed < 0) ? failure : null;
        },
      ));

  @override
  Widget build(BuildContext context) {
    final int numLanes = widget.appInfo.numLanes(widget.config);

    late final BoxConstraints numConstraints = BoxConstraints.tightFor(
        width: ezTextSize('000', context: context, style: widget.config.bodyStyle).width +
            (2 * widget.config.padding));

    late final _TimerConfig init = _TimerConfig(
      size: widget._size,
      setAutoDialog: () => setAutoDialog(numConstraints),
      ourCon: ourCon,
      minCon: minCon,
      secCon: secCon,
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
                    icon: const Icon(Icons.timer_outlined),
                    onPressed: () async {
                      final int ours = _toInt(ourCon.text);
                      final int mins = _toInt(minCon.text);
                      final int secs = _toInt(secCon.text);

                      ((ours + mins + secs) > 0)
                          ? await setTimer(<int>[ours, mins, secs])
                          : await setAutoDialog(numConstraints);
                    },
                    onLongPress: () => canToggleMenu(widget.config, controller),
                  )
                : EzRow(widget.config, children: <Widget>[
                    // Hours
                    timeField(numConstraints, ourCon, ourNode, () {
                      removeOverlay();
                      minNode.requestFocus();
                      minCon.selection =
                          TextSelection(baseOffset: 0, extentOffset: minCon.text.length);
                    }),
                    widget.config.rowMargin,

                    // Minutes
                    timeField(numConstraints, minCon, minNode, () {
                      removeOverlay();
                      secNode.requestFocus();
                      secCon.selection =
                          TextSelection(baseOffset: 0, extentOffset: secCon.text.length);
                    }),
                    widget.config.rowMargin,

                    // Seconds
                    timeField(
                      numConstraints,
                      secCon,
                      secNode,
                      () async {
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
                  ]),
            menuChildren: widgetMC(
              widget.config,
              widget.appInfo,
              _EditTimer(
                widget.config,
                widget.appInfo,
                parentCon: context,
                initConfig: init,
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
              _EditTimer(
                widget.config,
                widget.appInfo,
                parentCon: context,
                initConfig: init,
                lane: widget.pos.lane,
                index: widget.pos.index,
              ),
              numLanes: numLanes,
              lane: widget.pos.lane,
              index: widget.pos.index,
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

class AddTimer extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final WidgetSize save;
  final WidgetSize preview;

  const AddTimer(
    this.config,
    this.appInfo,
    this.lane, {
    super.key,
    required this.save,
    required this.preview,
  });

  void onTap() => appInfo.addTimer(config, lane);

  @override
  Widget build(BuildContext context) {
    late final Widget fauxTimerField = EzTextField(
      constraints: BoxConstraints(
          maxWidth:
              ezTextSize('00', context: context, style: config.bodyStyle).width + config.padding),
      hintText: '00',
      onTap: onTap,
      readOnly: true,
      validator: null,
    );

    return (preview == WidgetSize.button)
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
                EzIconButton(
                  config,
                  onPressed: onTap,
                  icon: const Icon(Icons.timer),
                ),
              ],
            ),
          );
  }
}

class _EditTimer extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext parentCon;
  final _TimerConfig initConfig;
  final int lane;
  final int index;

  const _EditTimer(
    this.config,
    this.appInfo, {
    required this.parentCon,
    required this.initConfig,
    required this.lane,
    required this.index,
  });

  @override
  Widget build(_) => SubmenuButton(
        menuChildren: <Widget>[
          EzMenuButton(
            config,
            label: 'Resize',
            onPressed: () async {
              final String? choice = await resizeWidgetDialog(config, parentCon, initConfig.size);
              if (choice == null) return;

              await appInfo.updateWidget(
                config,
                WidWidGetGet.timer,
                TCC.timerEntry(
                  WSConfig.safeLookup(choice),
                  <String>[
                    _validateTime(initConfig.ourCon.text),
                    _validateTime(initConfig.minCon.text),
                    _validateTime(initConfig.secCon.text),
                  ].join(':'),
                ),
                lane: lane,
                index: index,
              );
            },
          ),
          EzMenuButton(
            config,
            label: 'Set auto',
            onPressed: () async {
              final String ourBackup = initConfig.ourCon.text;
              final String minBackup = initConfig.ourCon.text;
              final String secBackup = initConfig.ourCon.text;

              final bool save = (await initConfig.setAutoDialog() == true);
              if (save) {
                await appInfo.updateWidget(
                  config,
                  WidWidGetGet.timer,
                  TCC.timerEntry(
                    initConfig.size,
                    <String>[
                      _validateTime(initConfig.ourCon.text),
                      _validateTime(initConfig.minCon.text),
                      _validateTime(initConfig.secCon.text),
                    ].join(':'),
                  ),
                  lane: lane,
                  index: index,
                );
              } else {
                initConfig.ourCon.text = ourBackup;
                initConfig.minCon.text = minBackup;
                initConfig.secCon.text = secBackup;
              }
            },
          ),
        ],
        child: EzIcon(config, Icons.edit),
      );
}

class _TimerConfig {
  final WidgetSize size;
  final Future<bool?> Function() setAutoDialog;
  final TextEditingController ourCon;
  final TextEditingController minCon;
  final TextEditingController secCon;

  _TimerConfig({
    required this.size,
    required this.setAutoDialog,
    required this.ourCon,
    required this.minCon,
    required this.secCon,
  });
}

String _validateTime(String time) {
  final int? value = int.tryParse(time);
  return (value == null) ? '00' : ((value > 99) ? '99' : time);
}

int _toInt(String time) {
  final int? value = int.tryParse(time);
  return (value == null) ? 0 : ((value > 99) ? 99 : value);
}
