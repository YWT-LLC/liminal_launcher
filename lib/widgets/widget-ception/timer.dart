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
  late final List<String> _times;

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
    _times = (storage.length == 3) ? storage : <String>['00', '00', '00'];
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

  late final TextEditingController ourCon = TextEditingController(text: widget._times[0]);
  late final TextEditingController minCon = TextEditingController(text: widget._times[1]);
  late final TextEditingController secCon = TextEditingController(text: widget._times[2]);

  late final FocusNode ourNode = FocusNode();
  late final FocusNode minNode = FocusNode();
  late final FocusNode secNode = FocusNode();

  OverlayEntry? overlayEntry;

  Widget timeField(
    BoxConstraints constraints,
    TextEditingController controller,
    FocusNode curr,
    void Function() onSubmit, {
    bool last = false,
    bool useOverlay = true,
  }) =>
      ConstrainedBox(
        constraints: constraints,
        child: TextFormField(
          controller: controller,
          focusNode: curr,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.number,
          textInputAction: last ? TextInputAction.done : TextInputAction.next,
          validator: (String? value) {
            const String failure = '0-99';

            if (value == null) return failure;
            final int parsed = int.tryParse(value) ?? -1;

            return (parsed > 99 || parsed < 0) ? failure : null;
          },
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
        ),
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

  Future<dynamic> setAutoDialog(BoxConstraints constraints) => showDialog(
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

  @override
  Widget build(BuildContext context) {
    final int numLanes = widget.appInfo.numLanes(widget.config);

    final BoxConstraints numConstraints = BoxConstraints.tightFor(
      width: ezTextSize('000', context: context, style: widget.config.bodyStyle).width +
          (2 * widget.config.padding),
      height: appIconSize(widget.config),
    );

    late final EzMenuButton setAuto = EzMenuButton(
      widget.config,
      label: 'Auto duration',
      icon: EzIcon(widget.config, Icons.edit),
      onPressed: () async {
        final String ourBackup = ourCon.text;
        final String minBackup = ourCon.text;
        final String secBackup = ourCon.text;

        final bool save = await setAutoDialog(numConstraints);

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
        );
        setState(() => size = trueChoice);
      },
    );

    late final EzMenuButton remove = EzMenuButton(
      widget.config,
      label: 'Remove',
      icon: EzIcon(widget.config, Icons.delete),
      onPressed: () => widget.appInfo.deleteWS(
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
                    iconSize: appIconSize(widget.config),
                    icon: const Icon(Icons.timer_outlined),
                    onPressed: () async {
                      final int ours = int.tryParse(ourCon.text) ?? 0;
                      final int mins = int.tryParse(minCon.text) ?? 0;
                      final int secs = int.tryParse(secCon.text) ?? 0;

                      ((ours + mins + secs) > 0)
                          ? await setTimer(<int>[ours, mins, secs])
                          : await setAutoDialog(numConstraints);
                    },
                    onLongPress: () => toggleMenu(controller),
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
                          int.tryParse(ourCon.text) ?? 0,
                          int.tryParse(minCon.text) ?? 0,
                          int.tryParse(secCon.text) ?? 0,
                        ]);
                      },
                      last: true,
                    ),
                    widget.config.rowMargin,

                    EzIconButton(
                      widget.config,
                      icon: EzIcon(widget.config, Icons.timer_outlined),
                      onPressed: () async {
                        removeOverlay();
                        await setTimer(<int>[
                          int.tryParse(ourCon.text) ?? 0,
                          int.tryParse(minCon.text) ?? 0,
                          int.tryParse(secCon.text) ?? 0,
                        ]);
                      },
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
                  label: 'Move -',
                  icon: EzIcon(widget.config, Icons.keyboard_arrow_down),
                  onPressed: () => widget.appInfo.moveItemDown(
                    widget.config,
                    lane: widget.lane,
                    index: widget.index,
                  ),
                ),
              if (numLanes > 1 && widget.lane < (numLanes - 1))
                EzMenuButton(
                  widget.config,
                  label: 'Move +',
                  icon: EzIcon(widget.config, Icons.keyboard_arrow_up),
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
    ourNode.dispose();
    minNode.dispose();
    secNode.dispose();

    removeOverlay();
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}
