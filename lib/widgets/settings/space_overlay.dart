/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:math';
import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

class _SpacingOverlay extends OverlayEntry {
  final EzCP config;
  final AppInfoProvider appInfo;
  final Completer<_ExitData?> completer;

  _SpacingOverlay(this.config, {required this.appInfo, required this.completer})
      : super(builder: (BuildContext context) {
          if (marked.value == null) return const SizedBox.shrink();

          //* Define build data *//
          // Init //

          final String? initDelim = tileRegex
              .firstMatch(appInfo.homeItem(
                config,
                lane: marked.value!.lane,
                index: marked.value!.index,
              ))
              ?.group(0);
          if (initDelim == null) return const SizedBox.shrink();

          final List<String> initData = appInfo
              .homeItem(config, lane: marked.value!.lane, index: marked.value!.index)
              .split(initDelim);

          // Final //

          final int numLanes = appInfo.numLanes(config);

          final double appIS = appIconSize(config);
          final Widget rowSpacer = EzSpacer(appIS, vertical: false);
          final double halfSpace = config.spacing / 2;

          final double fullHeight = heightOf(context);
          final double maxHeight = fullHeight * 0.75;

          final double fullWidth = widthOf(context);
          final double maxWidth = fullWidth * 0.75;

          // Stateful //

          // Shared
          bool showControls = true;
          double step = 1.0;

          int currLane = marked.value!.lane;
          int currIndex = marked.value!.index;

          ListAlignment hAlign = marked.value!.hAlign;
          ListAlignment vAlign = marked.value!.vAlign;

          bool tile = (initDelim != spacerSplit);

          // Spacer
          late Axis axis = Axis.vertical;

          late double hBack = double.tryParse(initData[0]) ?? config.spacing;
          late double height = hBack;

          late double wBack = double.tryParse(initData[1]) ?? appIS;
          late double width = wBack;

          if (!tile) editSpacerSize.value = Size(width, height);

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

          if (tile) {
            editTilePadding.value =
                EdgeInsets.only(top: top, bottom: bottom, left: left, right: right);
          }

          return StatefulBuilder(builder: (BuildContext oCon, StateSetter setOverlay) {
            //* Define custom functions *//

            marked.addListener(() async {
              if (marked.value == null ||
                  (currLane == marked.value!.lane && currIndex == marked.value!.index)) {
                return;
              }

              await ezNoTouch(() async {
                await appInfo.updateSpacing(
                  config,
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

                final RegExpMatch? newSplit = tileRegex.firstMatch(appInfo.homeItem(
                  config,
                  lane: marked.value!.lane,
                  index: marked.value!.index,
                ));
                final String? newDelim = newSplit?.group(0);
                if (newDelim == null) return;

                final List<String> newData = appInfo
                    .homeItem(config, lane: marked.value!.lane, index: marked.value!.index)
                    .split(newDelim);

                currLane = marked.value!.lane;
                currIndex = marked.value!.index;

                hAlign = marked.value!.hAlign;
                vAlign = marked.value!.vAlign;

                if (newDelim == spacerSplit) {
                  tile = false;

                  hBack = double.tryParse(newData[0]) ?? config.spacing;
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

              if (oCon.mounted) setOverlay(() {});
            });

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

            List<Widget> dynamicSteps() => <String, double>{
                  config.ezL10n.dsMargin: config.marginVal,
                  config.ezL10n.dsPadding: config.padding,
                  config.ezL10n.dsSpacing: config.spacing,
                  config.ezL10n.tsIconSize: config.iconSize,
                  l10n(config).mcIconButton: appIS,
                }
                    .entries
                    .map((MapEntry<String, double> entry) => EzMenuButton(
                          config,
                          label: '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                          icon: step == entry.value ? EzIcon(config, Icons.circle) : null,
                          textStyle: config.bodyStyle,
                          onPressed: () => setOverlay(() => step = entry.value),
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

              setOverlay(() {});
            }

            //* Return the build *//

            return Material(
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
                  top: config.spacing,
                  left: standardFlow(config) ? config.spacing : null,
                  right: standardFlow(config) ? null : config.spacing,
                  child: GestureDetector(
                    onTap: () => setOverlay(() => showControls = !showControls),
                    child: Icon(
                      showControls ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                      size: config.iconSize,
                    ),
                  ),
                ),

                Positioned(
                  top: safeTop(context),
                  left: 0,
                  right: 0,
                  child: EzAnimVis(
                    config,
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
                                          AxisDirection.up => l10n(config).gTop,
                                          AxisDirection.down => l10n(config).gBottom,
                                          AxisDirection.left => l10n(config).gLeft,
                                          AxisDirection.right => l10n(config).gRight,
                                        }
                                      : (axis == Axis.vertical)
                                          ? l10n(config).gVertical
                                          : l10n(config).gHorizontal,
                                  onPressed: () => toggleMenu(c),
                                ),
                                menuChildren: tile
                                    ? AxisDirection.values
                                        .map((AxisDirection dir) => EzMenuButton(
                                              config,
                                              label: switch (dir) {
                                                AxisDirection.up => l10n(config).gTop,
                                                AxisDirection.down => l10n(config).gBottom,
                                                AxisDirection.left => l10n(config).gLeft,
                                                AxisDirection.right => l10n(config).gRight,
                                              },
                                              icon: EzIcon(
                                                config,
                                                switch (dir) {
                                                  AxisDirection.up => Icons.north,
                                                  AxisDirection.down => Icons.south,
                                                  AxisDirection.left => Icons.west,
                                                  AxisDirection.right => Icons.east,
                                                },
                                              ),
                                              onPressed: () => setOverlay(() => side = dir),
                                            ))
                                        .toList()
                                    : Axis.values
                                        .map((Axis a) => EzMenuButton(
                                              config,
                                              label: a.name,
                                              icon: EzIcon(
                                                config,
                                                (a == Axis.vertical)
                                                    ? Icons.height
                                                    : Icons.horizontal_rule,
                                              ),
                                              onPressed: () => setOverlay(() => axis = a),
                                            ))
                                        .toList(),
                              ),
                              rowSpacer,

                              // Key/quick values
                              MenuAnchor(
                                builder: (_, MenuController c, __) => EzIconButton(
                                  config,
                                  icon: const Icon(Icons.key),
                                  tooltip: l10n(config).gKey,
                                  onPressed: () => toggleMenu(c),
                                ),
                                menuChildren: <String, double>{
                                  config.ezL10n.dsMargin: config.marginVal,
                                  config.ezL10n.dsPadding: config.padding,
                                  config.ezL10n.dsSpacing: config.spacing,
                                  config.ezL10n.tsIconSize: config.iconSize,
                                  l10n(config).mcIconButton: appIS,
                                  '1/4': (axis == Axis.horizontal ? fullHeight : fullWidth) * 0.250,
                                  '1/3': (axis == Axis.horizontal ? fullHeight : fullWidth) * 0.333,
                                  '1/2': (axis == Axis.horizontal ? fullHeight : fullWidth) * 0.500,
                                  '2/3': (axis == Axis.horizontal ? fullHeight : fullWidth) * 0.667,
                                  '3/4': (axis == Axis.horizontal ? fullHeight : fullWidth) * 0.750,
                                }
                                    .entries
                                    .map((MapEntry<String, double> entry) => EzMenuButton(
                                          config,
                                          icon: entry.key.contains('/')
                                              ? EzIcon(config, Icons.phone_android)
                                              : null,
                                          label: '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                                          textStyle: config.bodyStyle,
                                          onPressed: () => setValue(entry.value),
                                        ))
                                    .toList(),
                              ),
                              rowSpacer,

                              // Edits
                              MenuAnchor(
                                builder: (_, MenuController controller, __) => EzIconButton(
                                  config,
                                  icon: const Icon(Icons.build),
                                  tooltip: l10n(config).gEdits,
                                  onPressed: () => toggleMenu(controller),
                                ),
                                menuChildren: <Widget>[
                                  // Done
                                  EzMenuButton(
                                    config,
                                    label: l10n(config).mcDone,
                                    icon: EzIcon(config, Icons.done),
                                    onPressed: () => completer.complete(_ExitData(
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
                                      config,
                                      label: l10n(config).gDupe,
                                      icon: EzIcon(config, Icons.copy),
                                      onPressed: () async {
                                        await appInfo.updateSpacing(
                                          config,
                                          lane: currLane,
                                          index: currIndex,
                                          entry: <String>[height.toString(), width.toString()]
                                              .join(colon),
                                        );

                                        await appInfo.addSpacer(
                                          config,
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
                                        setOverlay(() => currIndex += 1);
                                      },
                                    ),

                                  // Reset
                                  EzMenuButton(
                                    config,
                                    label: l10n(config).gReset,
                                    icon: EzIcon(config, Icons.refresh),
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

                                      setOverlay(() {});
                                    },
                                  ),

                                  // Delete (conditional)
                                  if (!tile)
                                    EzMenuButton(
                                      config,
                                      label: l10n(config).mcDelete,
                                      icon: EzIcon(config, Icons.delete),
                                      onPressed: () => completer.complete(_ExitData(
                                        lane: currLane,
                                        index: currIndex,
                                        entry: <String>[height.toString(), width.toString()]
                                            .join(colon),
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
                                    tooltip: standardFlow(config)
                                        ? l10n(config).mcMoveLeft
                                        : l10n(config).mcMoveRight,
                                    onPressed: () async {
                                      final int nextLane = currLane - 1;
                                      final int nextIndex =
                                          appInfo.homeLane(config, nextLane).length;

                                      marked.value = LimPos(
                                        lane: nextLane,
                                        index: nextIndex,
                                        hAlign: hAlign,
                                        vAlign: vAlign,
                                      );
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
                                  tooltip: standardFlow(config)
                                      ? l10n(config).mcMoveUp
                                      : l10n(config).mcMoveDown,
                                  enabled:
                                      currIndex < (appInfo.homeLane(config, currLane).length - 1),
                                  onPressed: () async {
                                    final int nextIndex = currIndex + 1;

                                    marked.value = LimPos(
                                      lane: currLane,
                                      index: nextIndex,
                                      hAlign: hAlign,
                                      vAlign: vAlign,
                                    );
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
                                  tooltip: standardFlow(config)
                                      ? l10n(config).mcMoveDown
                                      : l10n(config).mcMoveUp,
                                  enabled: currIndex > 1, // 0 == config entry
                                  onPressed: () async {
                                    final int nextIndex = currIndex - 1;

                                    marked.value = LimPos(
                                      lane: currLane,
                                      index: nextIndex,
                                      hAlign: hAlign,
                                      vAlign: vAlign,
                                    );
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
                                    tooltip: standardFlow(config)
                                        ? l10n(config).mcMoveRight
                                        : l10n(config).mcMoveLeft,
                                    onPressed: () async {
                                      final int nextLane = currLane + 1;
                                      final int nextIndex =
                                          appInfo.homeLane(config, nextLane).length;

                                      marked.value = LimPos(
                                        lane: nextLane,
                                        index: nextIndex,
                                        hAlign: hAlign,
                                        vAlign: vAlign,
                                      );
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
                          icon: const Icon(Icons.keyboard_arrow_left),
                          tooltip: config.ezL10n.gDecrease,
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
                      config.rowMargin,

                      // Slide
                      Expanded(
                        child: EzTextBackground(
                          config,
                          borderRadius: config.buttonShape.radius,
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
                          backgroundColor: config.colors.surface,
                        ),
                      ),
                      config.rowMargin,

                      // Step up
                      MenuAnchor(
                        builder: (_, MenuController c, __) => EzIconButton(
                          config,
                          icon: const Icon(Icons.keyboard_arrow_right),
                          tooltip: config.ezL10n.gIncrease,
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
          });
        });
}

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

// TODO: get semantics working on the overlay

Future<void> editSpacing(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext context,
}) async {
  final Completer<_ExitData?> completer = Completer<_ExitData?>();
  final OverlayEntry overlayEntry = _SpacingOverlay(config, appInfo: appInfo, completer: completer);

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
