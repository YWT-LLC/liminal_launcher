/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:open_ui/open_ui.dart';

//* Core Widget *//

class LimSpacer extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final LimPos pos;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  final void Function() resizeCallback;

  late final double _height;
  late final double _width;

  LimSpacer(
    this.config, {
    super.key,
    required this.appInfo,
    required this.pos,
    required this.state,
    required this.rippleProgress,
    required this.resizeCallback,
  }) {
    final List<String> data = appInfo
        .homeItem(config, lane: pos.lane, index: pos.index)
        .split(spacerSplit);

    _height = double.tryParse(data[0]) ?? config.spacing;
    _width = double.tryParse(data[1]) ?? appIconSize(config);
  }

  @override
  State<LimSpacer> createState() => _LimSpacerState();
}

class _LimSpacerState extends State<LimSpacer> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

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
          AppState.standard => AppState.groupEdit,
          _ => AppState.standard,
        },
      );

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
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final int numLanes = widget.appInfo.numLanes(widget.config);

    return ValueListenableBuilder<(int?, int?)>(
      valueListenable: marked,
      builder: (_, (int?, int?) pos, __) =>
          (pos.$1 == widget.pos.lane && pos.$2 == widget.pos.index)
          ? _LiveSpacer(widget.config)
          : EzAnimSwitch(
              widget.config,
              mod: 0.667,
              forceFade: true,
              forceType: EzTransitionType.none,
              child: (state == AppState.standard)
                  ? MenuAnchor(
                      builder: (_, MenuController controller, __) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: () => canToggleMenu(widget.config, controller),
                        child: SizedBox(height: widget._height, width: widget._width),
                      ),
                      menuChildren: _menuChildren(
                        widget.config,
                        appInfo: widget.appInfo,
                        state: state,
                        stateCheck: doNothing,
                        numLanes: numLanes,
                        pos: widget.pos,
                      ),
                    )
                  : EditContainer(
                      widget.config,
                      subAlign: widget.pos.subAlign,
                      menuControl: menuControl,
                      menuChildren: _menuChildren(
                        widget.config,
                        appInfo: widget.appInfo,
                        state: state,
                        stateCheck: widget.resizeCallback,
                        numLanes: numLanes,
                        pos: widget.pos,
                      ),
                      child: EzIconButton(
                        widget.config,
                        icon: const Icon(Icons.space_bar),
                        onPressed: () => toggleMenu(menuControl),
                      ),
                    ),
            ),
    );
  }

  @override
  void dispose() {
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}

List<Widget> _menuChildren(
  EzCP config, {
  required AppInfoProvider appInfo,
  required AppState state,
  required void Function() stateCheck,
  required int numLanes,
  required LimPos pos,
}) => <Widget>[
  // Edit
  _EditSpacer(config, appInfo, pos: pos, stateCheck: stateCheck),

  // Dupe
  EzMenuButton(
    config,
    label: 'Duplicate',
    icon: EzIcon(config, Icons.copy),
    onPressed: () => appInfo.dupeItem(
      config,
      editNew: () async {
        if (!ezRootIsMounted) return;
        await editSpacer(
          config,
          appInfo: appInfo,
          context: ezRootContext,
          lane: pos.lane,
          index: pos.index,
        );
      },
      lane: pos.lane,
      index: pos.index,
    ),
  ),

  // Move
  if (state == AppState.groupEdit && numLanes > 1) ...<Widget>[
    moveDownLane(config, appInfo, numLanes: numLanes, lane: pos.lane, index: pos.index),
    moveUpLane(config, appInfo, numLanes: numLanes, lane: pos.lane, index: pos.index),
  ],

  // Remove
  removeItem(config, appInfo, lane: pos.lane, index: pos.index),
];

//* Add Widget *//

class _LiveSpacer extends StatelessWidget {
  final EzCP config;

  const _LiveSpacer(this.config);

  @override
  Widget build(_) => ValueListenableBuilder<double>(
    valueListenable: editSpacerHeight,
    builder: (_, double height, __) => ValueListenableBuilder<double>(
      valueListenable: editSpacerWidth,
      builder: (_, double width, __) => Container(
        decoration: BoxDecoration(
          color: config.colors.secondary.withValues(alpha: focusOpacity),
          borderRadius: EzButtonShape.roundRect.radius,
          border: Border.all(color: config.colors.secondary, width: config.borderWidth),
        ),
        height: height,
        width: width,
      ),
    ),
  );
}

//* Edit Widget *//

Future<void> editSpacer(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext context,
  required int lane,
  required int index,
}) async {
  // Define build data //

  final int numLanes = appInfo.numLanes(config);

  final double appIS = appIconSize(config);
  final Widget rowSpacer = EzSpacer(appIS, vertical: false);

  int currLane = lane;
  int currIndex = index;
  final List<String> data = appInfo.homeItem(config, lane: lane, index: index).split(spacerSplit);

  final double hBack = double.tryParse(data[0]) ?? config.spacing;
  final double maxHeight = heightOf(context) * 0.75;
  double height = hBack;
  editSpacerHeight.value = height;

  final double wBack = double.tryParse(data[1]) ?? appIS;
  final double maxWidth = widthOf(context) * 0.75;
  double width = wBack;
  editSpacerWidth.value = width;

  marked.value = (lane, index);

  Axis axis = Axis.vertical;
  double step = 5.0;

  final Completer<bool?> completer = Completer<bool?>();
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (_) => StatefulBuilder(
      builder: (_, StateSetter setOverlay) {
        final String alignEntry = appInfo.homeItem(config, lane: lane, index: 0);
        final ListAlignment vAlign = LAConfig.buildLookup(alignEntry, Axis.vertical, config);

        // Define custom functions //

        List<Widget> staticSteps() => <int>[1, 5, 10]
            .map(
              (int value) => EzMenuButton(
                config,
                label: value.toString(),
                icon: step == value ? EzIcon(config, Icons.circle) : null,
                textAlign: TextAlign.center,
                textStyle: config.bodyStyle?.copyWith(fontWeight: FontWeight.bold),
                onPressed: () => setOverlay(() => step = value.toDouble()),
              ),
            )
            .toList();

        List<Widget> dynamicSteps() =>
            <String, double>{
                  config.ezL10n.dsMargin: config.marginVal,
                  config.ezL10n.dsPadding: config.padding,
                  config.ezL10n.dsSpacing: config.spacing,
                  config.ezL10n.tsIconSize: config.iconSize,
                  'Icon button size': appIS,
                }.entries
                .map(
                  (MapEntry<String, double> entry) => EzMenuButton(
                    config,
                    label: '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                    icon: step == entry.value ? EzIcon(config, Icons.circle) : null,
                    textAlign: TextAlign.center,
                    textStyle: config.bodyStyle,
                    onPressed: () => setOverlay(() => step = entry.value),
                  ),
                )
                .toList();

        late final List<Widget> stepOptions = staticSteps() + dynamicSteps();

        void quickValue(double value) {
          if (axis == Axis.vertical) {
            height = value;
            editSpacerHeight.value = value;
          } else {
            width = value;
            editSpacerWidth.value = value;
          }
          setOverlay(() {});
        }

        // Return the build //

        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: <Widget>[
              // Block app interactions //
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: doNothing,
                  onLongPress: doNothing,
                  child: const SizedBox.expand(),
                ),
              ),

              // Top: controls //
              Positioned(
                top: safeTop(context),
                left: 0,
                right: 0,
                child: Center(
                  child: EzCol(
                    children: <Widget>[
                      EzScrollView(
                        config,
                        startCentered: true,
                        showScrollHint: true,
                        mainAxisSize: MainAxisSize.max,
                        scrollDirection: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Slider select
                          MenuAnchor(
                            builder: (_, MenuController c, __) => EzIconButton(
                              config,
                              icon: Icon(
                                (axis == Axis.vertical) ? Icons.height : Icons.horizontal_rule,
                              ),
                              onPressed: () => toggleMenu(c),
                            ),
                            menuChildren: Axis.values
                                .map(
                                  (Axis a) => EzMenuButton(
                                    config,
                                    label: a.name,
                                    icon: EzIcon(
                                      config,
                                      (a == Axis.vertical) ? Icons.height : Icons.horizontal_rule,
                                    ),
                                    onPressed: () => setOverlay(() => axis = a),
                                  ),
                                )
                                .toList(),
                          ),
                          rowSpacer,

                          // Key/quick values
                          MenuAnchor(
                            builder: (_, MenuController c, __) => EzIconButton(
                              config,
                              icon: const Icon(Icons.key),
                              onPressed: () => toggleMenu(c),
                            ),
                            menuChildren: <Widget>[
                              MenuItemButton(
                                onPressed: () => quickValue(config.marginVal),
                                child: Text('Margin: ${config.marginVal}'),
                              ),
                              MenuItemButton(
                                onPressed: () => quickValue(config.padding),
                                child: Text('Padding: ${config.padding}'),
                              ),
                              MenuItemButton(
                                onPressed: () => quickValue(config.spacing),
                                child: Text('Spacing: ${config.spacing}'),
                              ),
                              MenuItemButton(
                                onPressed: () => quickValue(config.iconSize),
                                child: Text('Icon size: ${config.iconSize}'),
                              ),
                              MenuItemButton(
                                onPressed: () => quickValue(appIS),
                                child: Text('Icon button size: $appIS'),
                              ),
                            ],
                          ),
                          rowSpacer,

                          // Edits
                          MenuAnchor(
                            builder: (_, MenuController controller, __) => EzIconButton(
                              config,
                              icon: const Icon(Icons.build),
                              onPressed: () => toggleMenu(controller),
                            ),
                            menuChildren: <Widget>[
                              EzMenuButton(
                                config,
                                label: 'Done',
                                icon: EzIcon(config, Icons.done),
                                onPressed: () {
                                  overlayEntry.remove();
                                  completer.complete(true);
                                },
                              ),
                              EzMenuButton(
                                config,
                                label: 'Duplicate',
                                icon: EzIcon(config, Icons.copy),
                                onPressed: () async {
                                  await appInfo.updateSpacer(
                                    config,
                                    height: height,
                                    width: width,
                                    lane: currLane,
                                    index: currIndex,
                                  );
                                  await appInfo.addSpacer(
                                    config,
                                    height: height,
                                    width: width,
                                    lane: currLane,
                                    index: currIndex,
                                  );

                                  marked.value = (currLane, currIndex + 1);
                                  setOverlay(() => currIndex += 1);
                                },
                              ),
                              EzMenuButton(
                                config,
                                label: 'Reset',
                                icon: EzIcon(config, Icons.refresh),
                                onPressed: () {
                                  height = hBack;
                                  editSpacerHeight.value = hBack;

                                  width = wBack;
                                  editSpacerWidth.value = wBack;

                                  setOverlay(() {});
                                },
                              ),
                              EzMenuButton(
                                config,
                                label: 'Delete',
                                icon: EzIcon(config, Icons.delete),
                                onPressed: () {
                                  overlayEntry.remove();
                                  completer.complete(false);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      EzScrollView(
                        config,
                        startCentered: true,
                        showScrollHint: true,
                        mainAxisSize: MainAxisSize.max,
                        scrollDirection: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Move (lane) down
                          if (numLanes > 1) ...<Widget>[
                            EzIconButton(
                              config,
                              enabled: currLane > 0,
                              icon: Icon(
                                standardFlow(config)
                                    ? Icons.keyboard_arrow_left
                                    : Icons.keyboard_arrow_right,
                              ),
                              onPressed: () async {
                                final int nextLane = currLane - 1;
                                final int nextIndex = appInfo.homeLane(config, nextLane).length;

                                marked.value = (nextLane, nextIndex);
                                await appInfo.moveItemDownLane(
                                  config,
                                  lane: currLane,
                                  index: currIndex,
                                );

                                currLane = nextLane;
                                currIndex = nextIndex;

                                setOverlay(() {});
                              },
                            ),
                            rowSpacer,
                          ],

                          // Move (item) up
                          EzIconButton(
                            config,
                            icon: Icon(
                              vAlign == ListAlignment.end
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                            enabled: currIndex < (appInfo.homeLane(config, currLane).length - 1),
                            onPressed: () async {
                              final int nextIndex = currIndex + 1;

                              marked.value = (currLane, nextIndex);
                              await appInfo.reorderLane(
                                config,
                                lane: currLane,
                                oldIndex: currIndex,
                                newIndex: nextIndex,
                                notify: true,
                              );

                              setOverlay(() => currIndex = nextIndex);
                            },
                          ),
                          rowSpacer,

                          // Moved (item) down
                          EzIconButton(
                            config,
                            icon: Icon(
                              vAlign == ListAlignment.end
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                            ),
                            enabled: currIndex > 1, // Config entry
                            onPressed: () async {
                              final int nextIndex = currIndex - 1;

                              marked.value = (currLane, nextIndex);
                              await appInfo.reorderLane(
                                config,
                                lane: currLane,
                                oldIndex: currIndex,
                                newIndex: nextIndex,
                                notify: true,
                              );

                              setOverlay(() => currIndex = nextIndex);
                            },
                          ),

                          // Move (lane) up
                          if (numLanes > 1) ...<Widget>[
                            rowSpacer,
                            EzIconButton(
                              config,
                              enabled: currLane < (numLanes - 1),
                              icon: Icon(
                                standardFlow(config)
                                    ? Icons.keyboard_arrow_right
                                    : Icons.keyboard_arrow_left,
                              ),
                              onPressed: () async {
                                final int nextLane = currLane + 1;
                                final int nextIndex = appInfo.homeLane(config, nextLane).length;

                                marked.value = (nextLane, nextIndex);
                                await appInfo.moveItemUpLane(
                                  config,
                                  lane: currLane,
                                  index: currIndex,
                                );

                                currLane = nextLane;
                                currIndex = nextIndex;

                                setOverlay(() {});
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom: steps && sliders //
              Positioned(
                bottom: safeBottom(context),
                left: 0,
                right: 0,
                child: EzRow(
                  config,
                  reverseHands: false,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    // Step down
                    MenuAnchor(
                      builder: (_, MenuController c, __) => EzIconButton(
                        config,
                        enabled: (axis == Axis.vertical ? height : width) != 0,
                        icon: const Icon(Icons.keyboard_arrow_left),
                        onPressed: (axis == Axis.vertical)
                            ? () {
                                height -= step;
                                if (height < 0) height = 0;

                                editSpacerHeight.value = height;
                                setOverlay(() {});
                              }
                            : () {
                                width -= step;
                                if (width < 0) width = 0;

                                editSpacerWidth.value = width;
                                setOverlay(() {});
                              },
                        onLongPress: () => toggleMenu(c),
                      ),
                      menuChildren: stepOptions,
                    ),
                    config.rowMargin,

                    // Slide
                    Expanded(
                      child: EzTextBackground(
                        config,
                        shape: config.buttonShape,
                        text: (axis == Axis.vertical)
                            ? Slider(
                                value: height,
                                max: maxHeight,
                                onChanged: (double value) {
                                  editSpacerHeight.value = value;
                                  setOverlay(() => height = value);
                                },
                              )
                            : Slider(
                                value: width,
                                max: maxWidth,
                                onChanged: (double value) {
                                  editSpacerWidth.value = value;
                                  setOverlay(() => width = value);
                                },
                              ),
                        backgroundColor: config.colors.surface,
                      ),
                    ),
                    config.rowMargin,

                    // Step up
                    MenuAnchor(
                      builder: (_, MenuController c, __) => EzIconButton(
                        config,
                        enabled: (axis == Axis.vertical)
                            ? (height != maxHeight)
                            : (width != maxWidth),
                        icon: const Icon(Icons.keyboard_arrow_right),
                        onPressed: (axis == Axis.vertical)
                            ? () {
                                height += step;
                                if (height > maxHeight) height = maxHeight;

                                editSpacerHeight.value = height;
                                setOverlay(() {});
                              }
                            : () {
                                width += step;
                                if (width > maxWidth) width = maxWidth;

                                editSpacerWidth.value = width;
                                setOverlay(() {});
                              },
                        onLongPress: () => toggleMenu(c),
                      ),
                      menuChildren: stepOptions,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  ezRootOverlay?.insert(overlayEntry);
  final bool? keep = await completer.future;

  await ezNoTouch(() async {
    marked.value = (null, null);

    (keep == false)
        ? await appInfo.removeItem(config, lane: currLane, index: currIndex)
        : await appInfo.updateSpacer(
            config,
            height: height,
            width: width,
            lane: currLane,
            index: currIndex,
          );
  });
}

class _EditSpacer extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;

  final LimPos pos;
  final void Function() stateCheck;

  const _EditSpacer(this.config, this.appInfo, {required this.pos, required this.stateCheck});

  @override
  Widget build(_) => EzMenuButton(
    config,
    onPressed: () async {
      if (!ezRootIsMounted) return;

      stateCheck.call();
      await editSpacer(
        config,
        appInfo: appInfo,
        context: ezRootContext,
        lane: pos.lane,
        index: pos.index,
      );
    },
    icon: EzIcon(config, Icons.edit),
  );
}
