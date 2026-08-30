/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:math';
import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

//* Core Overlay *//

class _EditSpacingEntry extends OverlayEntry {
  _EditSpacingEntry(
    EzCP config, {
    required AppInfoProvider appInfo,
    required Completer<_ExitData?> completer,
  }) : super(builder: (_) {
          if (marked.value == null) return const SizedBox.shrink();
          return _EditSpacingOverlay(config, appInfo, completer);
        });
}

class _EditSpacingOverlay extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final Completer<_ExitData?> completer;

  const _EditSpacingOverlay(this.config, this.appInfo, this.completer);

  @override
  State<_EditSpacingOverlay> createState() => _EditSpacingOverlayState();
}

class _EditSpacingOverlayState extends State<_EditSpacingOverlay> {
  // Define build data //
  // Init data

  late final String? initDelim = tileRegex
      .firstMatch(widget.appInfo.homeItem(
        widget.config,
        lane: marked.value!.lane,
        index: marked.value!.index,
      ))
      ?.group(0);

  late final List<String> initData = widget.appInfo
      .homeItem(widget.config, lane: marked.value!.lane, index: marked.value!.index)
      .split(initDelim!); // null check in build

  // Final data

  late final int numLanes = widget.appInfo.numLanes(widget.config);

  late final double appIS = appIconSize(widget.config);
  late final Widget rowSpacer = EzSpacer(appIS, vertical: false);
  late final double halfSpace = widget.config.spacing / 2;

  late final double fullHeight = heightOf(context);
  late final double maxHeight = fullHeight * 0.75;

  late final double fullWidth = widthOf(context);
  late final double maxWidth = fullWidth * 0.75;

  // Stateful data

  // Shared
  bool showControls = true;
  double step = 1.0;

  int currLane = marked.value!.lane;
  int currIndex = marked.value!.index;

  ListAlignment hAlign = marked.value!.hAlign;
  ListAlignment vAlign = marked.value!.vAlign;

  late bool tile = (initDelim != spacerSplit);

  // Spacer
  late Axis axis = Axis.vertical;

  late double hBack = double.tryParse(initData[0]) ?? widget.config.spacing;
  late double height = hBack;

  late double wBack = double.tryParse(initData[1]) ?? appIS;
  late double width = wBack;

  // Tile
  late AxisDirection side = AxisDirection.up;

  late final List<String> paddingEntries = (switch (initDelim) {
    idSplit => initData[2],
    _ => initData[1],
  })
      .split(configSplit)[0]
      .split(colon);

  late double tBack = double.tryParse(paddingEntries[0]) ?? halfSpace;
  late double top = tBack;

  late double bBack = double.tryParse(paddingEntries[1]) ?? halfSpace;
  late double bottom = bBack;

  late double lBack = double.tryParse(paddingEntries[2]) ?? halfSpace;
  late double left = lBack;

  late double rBack = double.tryParse(paddingEntries[3]) ?? halfSpace;
  late double right = rBack;

  // Init //

  Future<void> _newMark() async {
    if (marked.value == null ||
        (currLane == marked.value!.lane && currIndex == marked.value!.index)) {
      return;
    }

    await ezNoTouch(() async {
      await widget.appInfo.updateSpacing(
        widget.config,
        lane: currLane,
        index: currIndex,
        entry: tile
            ? <String>[
                top.toString(),
                bottom.toString(),
                left.toString(),
                right.toString(),
              ].join(colon)
            : <String>[height.toString(), width.toString()].join(colon),
      );

      final RegExpMatch? newSplit = tileRegex.firstMatch(widget.appInfo.homeItem(
        widget.config,
        lane: marked.value!.lane,
        index: marked.value!.index,
      ));
      final String? newDelim = newSplit?.group(0);
      if (newDelim == null) return;

      final List<String> newData = widget.appInfo
          .homeItem(widget.config, lane: marked.value!.lane, index: marked.value!.index)
          .split(newDelim);

      currLane = marked.value!.lane;
      currIndex = marked.value!.index;

      hAlign = marked.value!.hAlign;
      vAlign = marked.value!.vAlign;

      if (newDelim == spacerSplit) {
        tile = false;

        hBack = double.tryParse(newData[0]) ?? widget.config.spacing;
        height = hBack;

        wBack = double.tryParse(newData[1]) ?? appIS;
        width = wBack;

        editSpacerSize.value = Size(width, height);
      } else {
        tile = true;

        final List<String> paddingEntries = (switch (newDelim) {
          idSplit => newData[2],
          _ => newData[1],
        })
            .split(configSplit)[0]
            .split(colon);

        tBack = double.tryParse(paddingEntries[0]) ?? halfSpace;
        top = tBack;

        bBack = double.tryParse(paddingEntries[1]) ?? halfSpace;
        bottom = bBack;

        lBack = double.tryParse(paddingEntries[2]) ?? halfSpace;
        left = lBack;

        rBack = double.tryParse(paddingEntries[3]) ?? halfSpace;
        right = rBack;

        editTilePadding.value = EdgeInsets.only(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
        );
      }
    });

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    if (tile) {
      editTilePadding.value = EdgeInsets.only(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
      );
    } else {
      editSpacerSize.value = Size(width, height);
    }

    marked.addListener(_newMark);
  }

  @override
  Widget build(BuildContext context) {
    // Define custom functions //

    List<Widget> staticSteps() => <int>[1, 5, 10]
        .map(
          (int value) => EzMenuButton(
            widget.config,
            label: value.toString(),
            icon: step == value ? EzIcon(widget.config, Icons.circle) : null,
            textAlign: TextAlign.center,
            textStyle: widget.config.bodyStyle?.copyWith(fontWeight: FontWeight.bold),
            onPressed: () => setState(() => step = value.toDouble()),
          ),
        )
        .toList();

    List<Widget> dynamicSteps() => <String, double>{
          widget.config.ezL10n.dsMargin: widget.config.marginVal,
          widget.config.ezL10n.dsPadding: widget.config.padding,
          widget.config.ezL10n.dsSpacing: widget.config.spacing,
          widget.config.ezL10n.tsIconSize: widget.config.iconSize,
          l10n(widget.config).mcIconButton: appIS,
        }
            .entries
            .map((MapEntry<String, double> entry) => EzMenuButton(
                  widget.config,
                  label: '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                  icon: step == entry.value ? EzIcon(widget.config, Icons.circle) : null,
                  textStyle: widget.config.bodyStyle,
                  onPressed: () => setState(() => step = entry.value),
                ))
            .toList();

    late final List<Widget> stepOptions = staticSteps() + dynamicSteps();

    void setValue(double value) {
      if (tile) {
        switch (side) {
          case AxisDirection.up:
            top = max(0, min(value, maxHeight * 0.5));
            break;
          case AxisDirection.down:
            bottom = max(0, min(value, maxHeight * 0.5));
            break;
          case AxisDirection.left:
            left = max(0, min(value, maxWidth * 0.5));
            break;
          case AxisDirection.right:
            right = max(0, min(value, maxWidth * 0.5));
            break;
        }

        editTilePadding.value = EdgeInsets.only(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
        );
      } else {
        if (axis == Axis.vertical) {
          height = max(0, min(value, maxHeight));
        } else {
          width = max(0, min(value, maxWidth));
        }
        editSpacerSize.value = Size(width, height);
      }

      setState(() {});
    }

    // Return the build //

    return (marked.value == null || initDelim == null)
        ? const SizedBox.shrink()
        : Material(
            type: MaterialType.transparency,
            child: Stack(children: <Widget>[
              // Block app interactions //
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onLongPress: doNothing,
                  child: const SizedBox.expand(),
                ),
              ),

              // Top: controls //
              Positioned(
                top: widget.config.spacing,
                left: standardFlow(widget.config) ? widget.config.spacing : null,
                right: standardFlow(widget.config) ? null : widget.config.spacing,
                child: GestureDetector(
                  onTap: () => setState(() => showControls = !showControls),
                  child: Icon(
                    showControls ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    size: widget.config.iconSize,
                  ),
                ),
              ),

              Positioned(
                top: safeTop(context),
                left: 0,
                right: 0,
                child: EzAnimVis(
                  widget.config,
                  forceType: EzTransitionType.slideY,
                  reverse: true,
                  forceFade: true,
                  mod: 0.667,
                  visible: showControls,
                  kid: Center(
                    child: EzCol(
                      children: <Widget>[
                        // Double top (const)
                        EzScrollView(
                          widget.config,
                          startCentered: true,
                          showScrollHint: true,
                          mainAxisSize: MainAxisSize.max,
                          scrollDirection: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // Slider select
                            MenuAnchor(
                              builder: (_, MenuController c, __) => EzIconButton(
                                widget.config,
                                icon: Icon(
                                  tile
                                      ? switch (side) {
                                          AxisDirection.up => Icons.north,
                                          AxisDirection.down => Icons.south,
                                          AxisDirection.left => Icons.west,
                                          AxisDirection.right => Icons.east,
                                        }
                                      : (axis == Axis.vertical)
                                          ? Icons.height
                                          : Icons.horizontal_rule,
                                ),
                                tooltip: tile
                                    ? switch (side) {
                                        AxisDirection.up => l10n(widget.config).gTop,
                                        AxisDirection.down => l10n(widget.config).gBottom,
                                        AxisDirection.left => l10n(widget.config).gLeft,
                                        AxisDirection.right => l10n(widget.config).gRight,
                                      }
                                    : (axis == Axis.vertical)
                                        ? l10n(widget.config).gVertical
                                        : l10n(widget.config).gHorizontal,
                                onPressed: () => toggleMenu(c),
                              ),
                              menuChildren: tile
                                  ? AxisDirection.values
                                      .map((AxisDirection dir) => EzMenuButton(
                                            widget.config,
                                            label: switch (dir) {
                                              AxisDirection.up => l10n(widget.config).gTop,
                                              AxisDirection.down => l10n(widget.config).gBottom,
                                              AxisDirection.left => l10n(widget.config).gLeft,
                                              AxisDirection.right => l10n(widget.config).gRight,
                                            },
                                            icon: EzIcon(
                                              widget.config,
                                              switch (dir) {
                                                AxisDirection.up => Icons.north,
                                                AxisDirection.down => Icons.south,
                                                AxisDirection.left => Icons.west,
                                                AxisDirection.right => Icons.east,
                                              },
                                            ),
                                            onPressed: () => setState(() => side = dir),
                                          ))
                                      .toList()
                                  : Axis.values
                                      .map((Axis a) => EzMenuButton(
                                            widget.config,
                                            label: a.name,
                                            icon: EzIcon(
                                              widget.config,
                                              (a == Axis.vertical)
                                                  ? Icons.height
                                                  : Icons.horizontal_rule,
                                            ),
                                            onPressed: () => setState(() => axis = a),
                                          ))
                                      .toList(),
                            ),
                            rowSpacer,

                            // Key/quick values
                            MenuAnchor(
                              builder: (_, MenuController c, __) => EzIconButton(
                                widget.config,
                                icon: const Icon(Icons.key),
                                tooltip: l10n(widget.config).gKey,
                                onPressed: () => toggleMenu(c),
                              ),
                              menuChildren: <String, double>{
                                widget.config.ezL10n.dsMargin: widget.config.marginVal,
                                widget.config.ezL10n.dsPadding: widget.config.padding,
                                widget.config.ezL10n.dsSpacing: widget.config.spacing,
                                widget.config.ezL10n.tsIconSize: widget.config.iconSize,
                                l10n(widget.config).mcIconButton: appIS,
                                '1/4': (axis == Axis.vertical ? fullHeight : fullWidth) * 0.250,
                                '1/3': (axis == Axis.vertical ? fullHeight : fullWidth) * 0.333,
                                '1/2': (axis == Axis.vertical ? fullHeight : fullWidth) * 0.500,
                                '2/3': (axis == Axis.vertical ? fullHeight : fullWidth) * 0.667,
                                '3/4': (axis == Axis.vertical ? fullHeight : fullWidth) * 0.750,
                              }
                                  .entries
                                  .map((MapEntry<String, double> entry) => EzMenuButton(
                                        widget.config,
                                        icon: entry.key.contains('/')
                                            ? EzIcon(widget.config, Icons.phone_android)
                                            : null,
                                        label: '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                                        textStyle: widget.config.bodyStyle,
                                        onPressed: () => setValue(entry.value),
                                      ))
                                  .toList(),
                            ),
                            rowSpacer,

                            // Edits
                            MenuAnchor(
                              builder: (_, MenuController controller, __) => EzIconButton(
                                widget.config,
                                icon: const Icon(Icons.build),
                                tooltip: l10n(widget.config).gEdits,
                                onPressed: () => toggleMenu(controller),
                              ),
                              menuChildren: <Widget>[
                                // Done
                                EzMenuButton(
                                  widget.config,
                                  label: l10n(widget.config).mcDone,
                                  icon: EzIcon(widget.config, Icons.done),
                                  onPressed: () => widget.completer.complete(_ExitData(
                                    lane: currLane,
                                    index: currIndex,
                                    entry: (tile
                                            ? <String>[
                                                top.toString(),
                                                bottom.toString(),
                                                left.toString(),
                                                right.toString(),
                                              ]
                                            : <String>[
                                                height.toString(),
                                                width.toString(),
                                              ])
                                        .join(colon),
                                    delete: false,
                                  )),
                                ),

                                // Dupe (conditional)
                                if (!tile)
                                  EzMenuButton(
                                    widget.config,
                                    label: l10n(widget.config).gDupe,
                                    icon: EzIcon(widget.config, Icons.copy),
                                    onPressed: () async {
                                      await widget.appInfo.updateSpacing(
                                        widget.config,
                                        lane: currLane,
                                        index: currIndex,
                                        entry: <String>[height.toString(), width.toString()]
                                            .join(colon),
                                      );

                                      await widget.appInfo.addSpacer(
                                        widget.config,
                                        height: height,
                                        width: width,
                                        lane: currLane,
                                        index: currIndex,
                                      );

                                      marked.value = LimPos(
                                        lane: currLane,
                                        index: currIndex + 1,
                                        hAlign: hAlign,
                                        vAlign: vAlign,
                                      );
                                      setState(() => currIndex += 1);
                                    },
                                  ),

                                // Reset
                                EzMenuButton(
                                  widget.config,
                                  label: l10n(widget.config).gReset,
                                  icon: EzIcon(widget.config, Icons.refresh),
                                  onPressed: () {
                                    if (tile) {
                                      top = tBack;
                                      bottom = bBack;
                                      left = lBack;
                                      right = rBack;

                                      editTilePadding.value = EdgeInsets.only(
                                        top: tBack,
                                        bottom: bBack,
                                        left: lBack,
                                        right: rBack,
                                      );
                                    } else {
                                      height = hBack;
                                      width = wBack;

                                      editSpacerSize.value = Size(width, height);
                                    }

                                    setState(() {});
                                  },
                                ),

                                // Delete (conditional)
                                if (!tile)
                                  EzMenuButton(
                                    widget.config,
                                    label: l10n(widget.config).mcDelete,
                                    icon: EzIcon(widget.config, Icons.delete),
                                    onPressed: () => widget.completer.complete(_ExitData(
                                      lane: currLane,
                                      index: currIndex,
                                      entry:
                                          <String>[height.toString(), width.toString()].join(colon),
                                      delete: true,
                                    )),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        // Top-bottom (conditional)
                        if (!tile)
                          EzScrollView(
                            widget.config,
                            startCentered: true,
                            showScrollHint: true,
                            mainAxisSize: MainAxisSize.max,
                            scrollDirection: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              // Move (lane) down
                              if (numLanes > 1) ...<Widget>[
                                EzIconButton(
                                  widget.config,
                                  enabled: currLane > 0,
                                  icon: Icon(
                                    standardFlow(widget.config)
                                        ? Icons.keyboard_arrow_left
                                        : Icons.keyboard_arrow_right,
                                  ),
                                  tooltip: standardFlow(widget.config)
                                      ? l10n(widget.config).mcMoveLeft
                                      : l10n(widget.config).mcMoveRight,
                                  onPressed: () async {
                                    final int nextLane = currLane - 1;
                                    final int nextIndex =
                                        widget.appInfo.homeLane(widget.config, nextLane).length;

                                    marked.value = LimPos(
                                      lane: nextLane,
                                      index: nextIndex,
                                      hAlign: hAlign,
                                      vAlign: vAlign,
                                    );
                                    await widget.appInfo.moveItemDownLane(
                                      widget.config,
                                      lane: currLane,
                                      index: currIndex,
                                    );

                                    currLane = nextLane;
                                    currIndex = nextIndex;

                                    setState(() {});
                                  },
                                ),
                                rowSpacer,
                              ],

                              // Move (item) up
                              EzIconButton(
                                widget.config,
                                icon: Icon(
                                  vAlign == ListAlignment.end
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                ),
                                tooltip: standardFlow(widget.config)
                                    ? l10n(widget.config).mcMoveUp
                                    : l10n(widget.config).mcMoveDown,
                                enabled: currIndex <
                                    (widget.appInfo.homeLane(widget.config, currLane).length - 1),
                                onPressed: () async {
                                  final int nextIndex = currIndex + 1;

                                  marked.value = LimPos(
                                    lane: currLane,
                                    index: nextIndex,
                                    hAlign: hAlign,
                                    vAlign: vAlign,
                                  );
                                  await widget.appInfo.reorderLane(
                                    widget.config,
                                    lane: currLane,
                                    oldIndex: currIndex,
                                    newIndex: nextIndex,
                                  );

                                  setState(() => currIndex = nextIndex);
                                },
                              ),
                              rowSpacer,

                              // Moved (item) down
                              EzIconButton(
                                widget.config,
                                icon: Icon(
                                  vAlign == ListAlignment.end
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_up,
                                ),
                                tooltip: standardFlow(widget.config)
                                    ? l10n(widget.config).mcMoveDown
                                    : l10n(widget.config).mcMoveUp,
                                enabled: currIndex > 1, // 0 == config entry
                                onPressed: () async {
                                  final int nextIndex = currIndex - 1;

                                  marked.value = LimPos(
                                    lane: currLane,
                                    index: nextIndex,
                                    hAlign: hAlign,
                                    vAlign: vAlign,
                                  );
                                  await widget.appInfo.reorderLane(
                                    widget.config,
                                    lane: currLane,
                                    oldIndex: currIndex,
                                    newIndex: nextIndex,
                                  );

                                  setState(() => currIndex = nextIndex);
                                },
                              ),

                              // Move (lane) up
                              if (numLanes > 1) ...<Widget>[
                                rowSpacer,
                                EzIconButton(
                                  widget.config,
                                  enabled: currLane < (numLanes - 1),
                                  icon: Icon(
                                    standardFlow(widget.config)
                                        ? Icons.keyboard_arrow_right
                                        : Icons.keyboard_arrow_left,
                                  ),
                                  tooltip: standardFlow(widget.config)
                                      ? l10n(widget.config).mcMoveRight
                                      : l10n(widget.config).mcMoveLeft,
                                  onPressed: () async {
                                    final int nextLane = currLane + 1;
                                    final int nextIndex =
                                        widget.appInfo.homeLane(widget.config, nextLane).length;

                                    marked.value = LimPos(
                                      lane: nextLane,
                                      index: nextIndex,
                                      hAlign: hAlign,
                                      vAlign: vAlign,
                                    );
                                    await widget.appInfo.moveItemUpLane(
                                      widget.config,
                                      lane: currLane,
                                      index: currIndex,
                                    );

                                    currLane = nextLane;
                                    currIndex = nextIndex;

                                    setState(() {});
                                  },
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom: steps && sliders //
              Positioned(
                bottom: safeBottom(context),
                left: 0,
                right: 0,
                child: EzRow(
                  widget.config,
                  reverseHands: false,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    // Step down
                    MenuAnchor(
                      builder: (_, MenuController c, __) => EzIconButton(
                        widget.config,
                        icon: const Icon(Icons.keyboard_arrow_left),
                        tooltip: widget.config.ezL10n.gDecrease,
                        onPressed: () {
                          final double base = tile
                              ? switch (side) {
                                  AxisDirection.up => top,
                                  AxisDirection.down => bottom,
                                  AxisDirection.left => left,
                                  AxisDirection.right => right,
                                }
                              : (axis == Axis.vertical ? height : width);

                          setValue(base - step);
                        },
                        onLongPress: () => toggleMenu(c),
                      ),
                      menuChildren: stepOptions,
                    ),
                    widget.config.rowMargin,

                    // Slide
                    Expanded(
                      child: EzTextBackground(
                        widget.config,
                        borderRadius: widget.config.buttonShape.radius,
                        text: (tile && (side == AxisDirection.up || side == AxisDirection.down) ||
                                (!tile && axis == Axis.vertical))
                            ? Slider(
                                value: tile ? (side == AxisDirection.up ? top : bottom) : height,
                                max: maxHeight * (tile ? 0.5 : 1),
                                onChanged: setValue,
                              )
                            : Slider(
                                value: tile ? (side == AxisDirection.left ? left : right) : width,
                                max: maxWidth * (tile ? 0.5 : 1),
                                onChanged: setValue,
                              ),
                        backgroundColor: widget.config.colors.surface,
                      ),
                    ),
                    widget.config.rowMargin,

                    // Step up
                    MenuAnchor(
                      builder: (_, MenuController c, __) => EzIconButton(
                        widget.config,
                        icon: const Icon(Icons.keyboard_arrow_right),
                        tooltip: widget.config.ezL10n.gIncrease,
                        onPressed: () {
                          final double base = tile
                              ? switch (side) {
                                  AxisDirection.up => top,
                                  AxisDirection.down => bottom,
                                  AxisDirection.left => left,
                                  AxisDirection.right => right,
                                }
                              : (axis == Axis.vertical ? height : width);

                          setValue(base + step);
                        },
                        onLongPress: () => toggleMenu(c),
                      ),
                      menuChildren: stepOptions,
                    ),
                  ],
                ),
              ),
            ]),
          );
  }

  @override
  void dispose() {
    marked.removeListener(_newMark);
    super.dispose();
  }
}

//* Completer *//

class _ExitData {
  final int lane;
  final int index;
  final String entry;
  final bool delete;

  _ExitData({
    required this.lane,
    required this.index,
    required this.entry,
    required this.delete,
  });
}

//* Func *//

Future<void> editSpacing(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext context,
}) async {
  final Completer<_ExitData?> completer = Completer<_ExitData?>();
  final OverlayEntry overlayEntry =
      _EditSpacingEntry(config, appInfo: appInfo, completer: completer);

  ezRootOverlay?.insert(overlayEntry);
  final _ExitData? data = await completer.future;
  overlayEntry.remove();

  await ezNoTouch(() async {
    marked.value = null;
    if (data == null) return;

    (data.delete)
        ? await appInfo.removeItem(config, lane: data.lane, index: data.index)
        : await appInfo.updateSpacing(
            config,
            lane: data.lane,
            index: data.index,
            entry: data.entry,
          );
  });
}
