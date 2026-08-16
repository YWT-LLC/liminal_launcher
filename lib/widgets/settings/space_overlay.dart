/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

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

          final RegExpMatch? splitMatch = tileRegex.firstMatch(appInfo.homeItem(
            config,
            lane: marked.value!.lane,
            index: marked.value!.index,
          ));
          final String? delim = splitMatch?.group(0);
          if (delim == null) return const SizedBox.shrink();

          final List<String> initData = appInfo
              .homeItem(config, lane: marked.value!.lane, index: marked.value!.index)
              .split(delim);

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
          double step = 1.0;

          int currLane = marked.value!.lane;
          int currIndex = marked.value!.index;

          ListAlignment hAlign = marked.value!.hAlign;
          ListAlignment vAlign = marked.value!.vAlign;

          bool tile = (delim != spacerSplit);

          // Spacer
          late Axis axis = Axis.vertical;

          late double hBack = double.tryParse(initData[0]) ?? config.spacing;
          late double height = hBack;
          if (!tile) editSpacerHeight.value = height;

          late double wBack = double.tryParse(initData[1]) ?? appIS;
          late double width = wBack;
          if (!tile) editSpacerWidth.value = width;

          // Tile
          late AxisDirection side = AxisDirection.up;

          late final List<String> paddingEntries = (switch (delim) {
            idSplit => initData[2],
            _ => initData[1],
          })
              .split(configSplit)[0]
              .split(':');

          late double tBack = double.tryParse(paddingEntries[0]) ?? halfSpace;
          late double top = tBack;
          // ??

          late double bBack = double.tryParse(paddingEntries[1]) ?? halfSpace;
          late double bottom = bBack;
          // ??

          late double lBack = double.tryParse(paddingEntries[2]) ?? halfSpace;
          late double left = lBack;
          // ??

          late double rBack = double.tryParse(paddingEntries[3]) ?? halfSpace;
          late double right = rBack;
          // ??

          return StatefulBuilder(builder: (_, StateSetter setOverlay) {
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
                        ].join(':')
                      : <String>[height.toString(), width.toString()].join(':'),
                );

                final RegExpMatch? splitMatch = tileRegex.firstMatch(appInfo.homeItem(
                  config,
                  lane: marked.value!.lane,
                  index: marked.value!.index,
                ));
                final String? delim = splitMatch?.group(0);
                if (delim == null) return;

                final List<String> newData = appInfo
                    .homeItem(config, lane: marked.value!.lane, index: marked.value!.index)
                    .split(delim);

                currLane = marked.value!.lane;
                currIndex = marked.value!.index;

                hAlign = marked.value!.hAlign;
                vAlign = marked.value!.vAlign;

                if (delim == spacerSplit) {
                  tile = false;

                  hBack = double.tryParse(newData[0]) ?? config.spacing;
                  height = hBack;
                  editSpacerHeight.value = height;

                  wBack = double.tryParse(newData[1]) ?? appIS;
                  width = wBack;
                  editSpacerWidth.value = width;
                } else {
                  tile = true;

                  final List<String> paddingEntries = (switch (delim) {
                    idSplit => initData[2],
                    _ => initData[1],
                  })
                      .split(configSplit)[0]
                      .split(':');

                  tBack = double.tryParse(paddingEntries[0]) ?? halfSpace;
                  top = tBack;
                  // ??

                  bBack = double.tryParse(paddingEntries[1]) ?? halfSpace;
                  bottom = bBack;
                  // ??

                  lBack = double.tryParse(paddingEntries[2]) ?? halfSpace;
                  left = lBack;
                  // ??

                  rBack = double.tryParse(paddingEntries[3]) ?? halfSpace;
                  right = rBack;
                  // ??
                }
              });

              setOverlay(() {});
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
                    top = value;
                    // ??
                    break;

                  case AxisDirection.down:
                    bottom = value;
                    // ??
                    break;

                  case AxisDirection.left:
                    left = value;
                    // ??
                    break;

                  case AxisDirection.right:
                    right = value;
                    // ??
                    break;
                }
              } else {
                if (axis == Axis.vertical) {
                  height = value;
                  editSpacerHeight.value = value;
                } else {
                  width = value;
                  editSpacerWidth.value = value;
                }
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
                  top: safeTop(context),
                  left: 0,
                  right: 0,
                  child: Center(
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
                                  (axis == Axis.vertical) ? Icons.height : Icons.horizontal_rule,
                                ),
                                onPressed: () => toggleMenu(c),
                              ),
                              menuChildren: tile
                                  ? AxisDirection.values
                                      .map((AxisDirection dir) => EzMenuButton(
                                            config,
                                            label: dir.name,
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
                                onPressed: () => toggleMenu(controller),
                              ),
                              menuChildren: <Widget>[
                                // Done
                                EzMenuButton(
                                  // TODO: tile aware
                                  config,
                                  label: l10n(config).mcDone,
                                  icon: EzIcon(config, Icons.done),
                                  onPressed: () => completer.complete(_ExitData(
                                    lane: currLane,
                                    index: currIndex,
                                    height: height,
                                    width: width,
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
                                  // TODO: tile aware
                                  config,
                                  label: l10n(config).gReset,
                                  icon: EzIcon(config, Icons.refresh),
                                  onPressed: () {
                                    height = hBack;
                                    editSpacerHeight.value = hBack;

                                    width = wBack;
                                    editSpacerWidth.value = wBack;

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
                                      height: height,
                                      width: width,
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
                                  onPressed: () async {
                                    final int nextLane = currLane - 1;
                                    final int nextIndex = appInfo.homeLane(config, nextLane).length;

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
                                  onPressed: () async {
                                    final int nextLane = currLane + 1;
                                    final int nextIndex = appInfo.homeLane(config, nextLane).length;

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
                                  max: maxHeight,
                                  onChanged: setValue,
                                )
                              : Slider(
                                  value: tile ? (side == AxisDirection.left ? left : right) : width,
                                  max: maxWidth,
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
                          enabled:
                              (axis == Axis.vertical) ? (height != maxHeight) : (width != maxWidth),
                          icon: const Icon(Icons.keyboard_arrow_right),
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
  final double height;
  final double width;
  final bool delete;

  _ExitData({
    required this.lane,
    required this.index,
    required this.height,
    required this.width,
    required this.delete,
  });
}

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
        : await appInfo.updateSpacer(
            config,
            height: data.height,
            width: data.width,
            lane: data.lane,
            index: data.index,
          );
  });
}
