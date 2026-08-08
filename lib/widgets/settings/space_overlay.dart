/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

class _SpacingOverlay extends OverlayEntry {
  final EzCP config;
  final AppInfoProvider appInfo;
  final LimPos pos;
  final Completer<_ExitData?> completer;

  _SpacingOverlay(
    this.config, {
    required this.appInfo,
    required this.pos,
    required this.completer,
  }) : super(builder: (BuildContext context) {
          //* Define build data *//
          // Final //

          // Edit-ee location
          final int numLanes = appInfo.numLanes(config);
          final int lane = pos.lane;
          final int index = pos.index;

          // Values
          final double appIS = appIconSize(config);

          final List<String> data =
              appInfo.homeItem(config, lane: lane, index: index).split(spacerSplit);

          final double fullHeight = heightOf(context);
          final double maxHeight = fullHeight * 0.75;
          final double hBack = double.tryParse(data[0]) ?? config.spacing;

          final double fullWidth = widthOf(context);
          final double maxWidth = fullWidth * 0.75;
          final double wBack = double.tryParse(data[1]) ?? appIS;

          // Widgets
          final Widget rowSpacer = EzSpacer(appIS, vertical: false);

          // Stateful //

          // Location
          int currLane = lane;
          int currIndex = index;

          marked.value = (lane, index);
          ListAlignment vAlign = LAConfig.buildLookup(
            appInfo.homeItem(config, lane: lane, index: 0),
            Axis.vertical,
            config,
          );

          // Values
          double height = hBack;
          editSpacerHeight.value = height;
          double width = wBack;
          editSpacerWidth.value = width;

          // User
          Axis axis = Axis.vertical;
          double step = 1.0;

          return StatefulBuilder(builder: (_, StateSetter setOverlay) {
            //* Define custom functions *//

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
              child: Stack(children: <Widget>[
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
                                        onPressed: () => quickValue(entry.value),
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
                                EzMenuButton(
                                  config,
                                  label: l10n(config).mcDone,
                                  icon: EzIcon(config, Icons.done),
                                  onPressed: () => completer.complete(_ExitData(
                                    lane: lane,
                                    index: index,
                                    height: height,
                                    width: width,
                                    delete: false,
                                  )),
                                ),
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

                                    marked.value = (currLane, currIndex + 1);
                                    setOverlay(() => currIndex += 1);
                                  },
                                ),
                                EzMenuButton(
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
                                EzMenuButton(
                                  config,
                                  label: l10n(config).mcDelete,
                                  icon: EzIcon(config, Icons.delete),
                                  onPressed: () => completer.complete(_ExitData(
                                    lane: lane,
                                    index: index,
                                    height: height,
                                    width: width,
                                    delete: true,
                                  )),
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
                              enabled: currIndex > 1, // 0 == config entry
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
                          borderRadius: config.buttonShape.radius,
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
                          enabled:
                              (axis == Axis.vertical) ? (height != maxHeight) : (width != maxWidth),
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
  required LimPos startPos,
}) async {
  final Completer<_ExitData?> completer = Completer<_ExitData?>();
  final OverlayEntry overlayEntry = _SpacingOverlay(
    config,
    appInfo: appInfo,
    pos: startPos,
    completer: completer,
  );

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
