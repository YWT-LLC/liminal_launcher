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
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final WidgetSize _size;
  late final bool _storedBool;
  late final List<String> _storedList;

  TimerWidget(
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

    final List<String> storage = data[2].split(':');

    if (storage.length == 3) {
      _storedBool = false;
      _storedList = <String>['00', '00', '00'];
    } else {
      _storedBool = (data[2] != '00:00:00');
      _storedList = storage;
    }
  }

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();
  late WidgetSize size = widget._size;

  late bool autoStart = widget._storedBool;

  late final TextEditingController ourCon = TextEditingController(text: widget._storedList[0]);
  late final TextEditingController minCon = TextEditingController(text: widget._storedList[1]);
  late final TextEditingController secCon = TextEditingController(text: widget._storedList[2]);

  Widget fauxButton(BoxConstraints constraints, TextFormField child) => Container(
        constraints: constraints,
        decoration: BoxDecoration(borderRadius: widget.config.buttonShape.radius),
        child: child,
      );

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

  String? validTime(String? value) {
    const String failure = '0-99';

    if (value == null) return failure;
    final int parsed = int.tryParse(value) ?? -1;

    return (parsed > 99 || parsed < 0) ? failure : null;
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

    final BoxConstraints numConstraints = BoxConstraints(
      maxWidth: ezTextSize('00', context: context, style: widget.config.titleStyle).width +
          widget.config.padding,
      maxHeight: appIconSize(widget.config),
    );

    late final EzMenuButton setAuto = EzMenuButton(
      widget.config,
      label: 'Auto duration',
      icon: EzIcon(widget.config, Icons.edit),
      onPressed: () async {
        final String ourBackup = ourCon.text;
        final String minBackup = ourCon.text;
        final String secBackup = ourCon.text;

        final bool save = await showDialog(
          context: context,
          builder: (BuildContext mCon) => EzAlertDialog(
            widget.config,
            content: EzRow(
              widget.config,
              reverseHands: false,
              children: <Widget>[
                ConstrainedBox(
                  constraints: numConstraints,
                  child: TextFormField(
                    controller: ourCon,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.number,
                    validator: validTime,
                  ),
                ),
                widget.config.rowMargin,
                ConstrainedBox(
                  constraints: numConstraints,
                  child: TextFormField(
                    controller: minCon,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.number,
                    validator: validTime,
                  ),
                ),
                widget.config.rowMargin,
                ConstrainedBox(
                  constraints: numConstraints,
                  child: TextFormField(
                    controller: secCon,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.number,
                    validator: validTime,
                  ),
                ),
              ],
            ),
            actions: ezActionPair(
              widget.config,
              onConfirm: () => Navigator.of(mCon).pop(true),
              onDeny: () => Navigator.of(mCon).pop(false),
              denyMsg: widget.config.ezL10n.gCancel,
            ),
            needsClose: false,
          ),
        );

        if (save) {
          await widget.appInfo.updateWidget(
            widget.config,
            WidWidGetGet.timer,
            size,
            extra: <String>[
              <String>[ourCon.text, minCon.text, secCon.text].join(':')
            ],
            lane: widget.lane,
            index: widget.index,
            notify: false,
          );
        } else {
          ourCon.text = ourBackup;
          minCon.text = minBackup;
          secCon.text = secBackup;
        }
      },
    );

    late final EzMenuButton resize = EzMenuButton(
      widget.config,
      label: 'Resize',
      icon: EzIcon(widget.config, Icons.edit),
      onPressed: () async {
        final String? choice = await resizeWidgetDialog(
          widget.config,
          context,
          size,
        );
        if (choice == null) return;
        final WidgetSize trueChoice = WSConfig.lookup(choice);

        await widget.appInfo.updateWidget(
          widget.config,
          WidWidGetGet.timer,
          trueChoice,
          extra: <String>[
            <String>[ourCon.text, minCon.text, secCon.text].join(':')
          ],
          lane: widget.lane,
          index: widget.index,
          notify: false,
        );
        setState(() => size = trueChoice);
      },
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
            builder: (_, MenuController controller, __) => (size == WidgetSize.button)
                ? EzIconButton(
                    widget.config,
                    icon: EzIcon(widget.config, Icons.timer_outlined),
                    onPressed: () => setTimer(
                      <int>[
                        int.tryParse(ourCon.text) ?? 0,
                        int.tryParse(minCon.text) ?? 0,
                        int.tryParse(secCon.text) ?? 0,
                      ],
                      autoStart,
                    ),
                    onLongPress: () => toggleMenu(controller),
                  )
                : EzRow(widget.config, children: <Widget>[
                    // Hours
                    fauxButton(
                      numConstraints,
                      TextFormField(
                        // TODO: add overlay (only for these, not dialog)
                        controller: ourCon,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        validator: validTime,
                      ),
                    ),
                    widget.config.rowMargin,

                    // Minutes
                    fauxButton(
                      numConstraints,
                      TextFormField(
                        controller: minCon,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        validator: validTime,
                      ),
                    ),
                    widget.config.rowMargin,

                    // Seconds
                    fauxButton(
                      numConstraints,
                      TextFormField(
                        controller: secCon,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        validator: validTime,
                      ),
                    ),
                    widget.config.rowMargin,

                    EzIconButton(
                      widget.config,
                      icon: EzIcon(widget.config, Icons.timer_outlined),
                      onPressed: () => setTimer(
                        <int>[
                          int.tryParse(ourCon.text) ?? 0,
                          int.tryParse(minCon.text) ?? 0,
                          int.tryParse(secCon.text) ?? 0,
                        ],
                        autoStart,
                      ),
                      onLongPress: () => toggleMenu(controller),
                    ),
                  ]),
            menuChildren: <Widget>[setAuto, resize, remove],
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
              resize,
              remove,
            ],
            child: EzIconButton(
              widget.config,
              iconSize: appIconSize(widget.config),
              icon: const Icon(Icons.timer_outlined),
              onPressed: () => toggleMenu(menuControl),
            ),
          ),
      },
    );
  }

  @override
  void dispose() {
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}
