/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//* Core 'Widget' *//

class LaneHeader extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext pContext;
  final int numLanes;
  final LimPos pos;
  final Future<void> Function(EzCP, AppInfoProvider, int, ListAlignment, ListAlignment) addModal;
  final void Function()? navPageDown;
  final void Function()? navPageUp;

  const LaneHeader(
    this.config, {
    super.key,
    required this.appInfo,
    required this.pContext,
    required this.numLanes,
    required this.pos,
    required this.addModal,
    required this.navPageDown,
    required this.navPageUp,
  });

  Future<void> _delete(BuildContext context) async {
    final bool deleted = await appInfo.removeLane(config, context, pos.lane);

    if (deleted == true) {
      (pos.lane != 0 ? navPageDown?.call() : (numLanes == 1 ? doNothing() : navPageUp?.call()));
    }
  }

  Future<void> _dupe() => appInfo.dupeLane(
        config,
        editNew: () => _editLane(
          config,
          appInfo: appInfo,
          context: pContext,
          lane: pos.lane,
          numLanes: numLanes + 1,
          hAlign: pos.hAlign,
          vAlign: pos.vAlign,
        ),
        lane: pos.lane,
      );

  @override
  Widget build(BuildContext context) => pages(config)
      ? Container(
          width: double.infinity,
          padding: EdgeInsets.only(bottom: config.spacing / 2),
          child: Center(
            child: EzScrollView(
              config,
              reverseHands: true,
              startCentered: true,
              showScrollHint: true,
              mainAxisSize: MainAxisSize.max,
              scrollDirection: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Delete
                EzIconButton(
                  config,
                  onPressed: () => _delete(context),
                  icon: const Icon(Icons.delete),
                ),
                config.rowSpacer,

                // Dupe
                EzIconButton(config, onPressed: _dupe, icon: const Icon(Icons.copy)),
                config.rowSpacer,

                // Edit
                EzIconButton(
                  config,
                  onPressed: () => _editLane(
                    config,
                    appInfo: appInfo,
                    context: context,
                    lane: pos.lane,
                    numLanes: numLanes,
                    hAlign: pos.hAlign,
                    vAlign: pos.vAlign,
                  ),
                  icon: const Icon(Icons.edit),
                ),
                config.rowSpacer,

                // Add
                EzIconButton(
                  config,
                  onPressed: () => addModal(config, appInfo, pos.lane, pos.hAlign, pos.vAlign),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        )
      : MenuAnchor(
          builder: (_, MenuController controller, __) => Padding(
            padding: EdgeInsets.only(bottom: config.spacing / 2),
            child: EzRow(
              config,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                EzIconButton(
                  config,
                  onPressed: () => toggleMenu(controller),
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
          menuChildren: <Widget>[
            // Add
            MenuItemButton(
              onPressed: () => addModal(config, appInfo, pos.lane, pos.hAlign, pos.vAlign),
              child: EzIcon(config, Icons.add),
            ),

            // Edit
            MenuItemButton(
              onPressed: () => _editLane(
                config,
                appInfo: appInfo,
                context: context,
                lane: pos.lane,
                numLanes: numLanes,
                hAlign: pos.hAlign,
                vAlign: pos.vAlign,
              ),
              child: EzIcon(config, Icons.edit),
            ),

            // Dupe
            MenuItemButton(onPressed: _dupe, child: EzIcon(config, Icons.copy)),

            // Delete
            MenuItemButton(onPressed: () => _delete(context), child: EzIcon(config, Icons.delete)),
          ],
        );
}

//* Add 'Widget' *//

class AddLane extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;

  const AddLane(
    this.config, {
    super.key,
    required this.appInfo,
  });

  Future<void> configMultiLane(BuildContext context, {bool rebuild = false}) async {
    bool usePage = pages(config);
    bool useWide = wideTiles(config);

    final TextStyle? focussed = config.bodyStyle;
    final TextStyle? hidden = config.labelStyle?.copyWith(color: config.colors.outline);

    await ezModal(
      config,
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (BuildContext mCon, StateSetter setModal) => ezModalScroll(
          config,
          children: <Widget>[
            // Title
            Text(
              'Multi-lane configuration',
              textAlign: TextAlign.center,
              style: config.titleStyle,
            ),
            config.spacer,

            // Switches
            EzSwitchPair(
              config,
              valueKey: config.isDark ? darkPagesKey : lightPagesKey,
              text: 'Pages',
              afterChanged: (bool? value) async {
                if (value == null) return;

                if (interlinked) {
                  await EzCM.setBool(
                    config.isDark ? lightPagesKey : darkPagesKey,
                    value,
                  );
                }
                setModal(() => usePage = value);
              },
            ),
            config.spacer,
            EzSwitchPair(
              config,
              valueKey: config.isDark ? darkWideTilesKey : lightWideTilesKey,
              text: 'Wide tiles',
              afterChanged: (bool? value) async {
                if (value == null) return;

                if (interlinked) {
                  await EzCM.setBool(
                    config.isDark ? lightWideTilesKey : darkWideTilesKey,
                    value,
                  );
                }
                setModal(() => useWide = value);
              },
            ),
            config.spacer,

            // Description
            EzRichText(
              config,
              children: <InlineSpan>[
                EzPlainText(
                  text: 'With pages enabled, lanes behave like pages on a traditional launcher.\n',
                  style: usePage ? focussed : hidden,
                ),
                EzPlainText(
                  text: 'With pages disabled, all lanes share one horizontal scroll.\n',
                  style: usePage ? hidden : focussed,
                ),
                config.richLine,
                EzPlainText(
                  text: 'With wide tiles enabled...\n',
                  style: useWide ? focussed : hidden,
                ),
                EzPlainText(
                  text: 'each lane (with an item) will be the width of one screen.\n',
                  style: usePage ? hidden : (useWide ? focussed : hidden),
                ),
                EzPlainText(
                  text:
                      'apps and folders can/will be activated anywhere in their horizontal space.\n',
                  style: useWide ? focussed : hidden,
                ),
                config.richLine,
                EzPlainText(
                  text: 'With wide tiles disabled...\n',
                  style: useWide ? hidden : focussed,
                ),
                EzPlainText(
                  text: 'lanes will be sized by their widest item & your spacing setting.\n',
                  style: usePage ? hidden : (useWide ? hidden : focussed),
                ),
                EzPlainText(
                  text:
                      'apps and folders can/will be activated only by their button(s). This affects scrolling as well.\n', // TODO: add scroll setting (with good name)
                  style: useWide ? hidden : focussed,
                ),
              ],
            ),
            config.separator,
          ],
        ),
      ),
    );

    if (rebuild && (usePage != pages(config) || useWide != wideTiles(config))) {
      await config.rebuildUI(allECT);
    }
  }

  @override
  Widget build(BuildContext context) => EzElevatedIconButton(
        config,
        onPressed: () async {
          if (appInfo.numLanes(config) == 1) await configMultiLane(context);
          await appInfo.addLane(config);

          if (EzCM.get(config.isDark ? darkPagesKey : lightPagesKey) != pages(config) ||
              EzCM.get(config.isDark ? darkWideTilesKey : lightWideTilesKey) != wideTiles(config)) {
            await config.rebuildUI(allECT);
          }
        },
        onLongPress: () async => (appInfo.numLanes(config) == 1)
            ? doNothing()
            : await configMultiLane(context, rebuild: true),
        label: 'Lane',
        icon: EzIcon(config, Icons.view_column_outlined),
      );
}

//* Edit 'Widget' *//

Future<void> _editLane(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext context,
  required int lane,
  required int numLanes,
  required ListAlignment hAlign,
  required ListAlignment vAlign,
}) async {
  final ListAlignment hDef = horizontalAlign(config);
  final ListAlignment vDef = verticalAlign(config);
  ListAlignment hA = hAlign;
  ListAlignment vA = vAlign;
  const double sizeMod = 0.333;

  int pos = lane;

  await ezModal(
    config,
    context: context,
    builder: (_) {
      List<Widget> buildNodes(StateSetter setModal) {
        final List<Widget> nodes = <Widget>[];

        for (int i = 0; i < numLanes; i++) {
          nodes.addAll(<Widget>[
            GestureDetector(
              onTap: () => setModal(() => pos = i),
              child: Container(
                constraints: BoxConstraints.tightFor(
                  height: appIconSize(config),
                  width: appIconSize(config),
                ),
                decoration: BoxDecoration(
                  color: i == pos
                      ? config.colors.secondary
                      : i == lane // this order is important
                          ? config.colors.tertiary
                          : config.colors.surface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    i.toString(),
                    textAlign: TextAlign.center,
                    style: config.labelStyle?.copyWith(
                      color: i == pos
                          ? config.colors.onSecondary
                          : i == lane
                              ? config.colors.onTertiary
                              : config.colors.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            EzSpacer(config.padding, vertical: false),
          ]);
        }
        nodes.removeLast();

        return nodes;
      }

      return StatefulBuilder(
        builder: (BuildContext mCon, StateSetter setModal) => ezModalScroll(
          config,
          children: <Widget>[
            // Move
            Text('Move', textAlign: TextAlign.center, style: config.labelStyle),
            config.margin,
            EzRow(
              config,
              reverseHands: false,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (numLanes > 1)
                  Padding(
                    padding: EdgeInsets.only(right: config.padding),
                    child: EzIconButton(
                      config,
                      enabled: pos > 0,
                      icon: const Icon(Icons.keyboard_arrow_left),
                      onPressed: () => setModal(() => pos -= 1),
                    ),
                  ),
                Expanded(
                  child: EzScrollView(
                    config,
                    scrollDirection: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: standardFlow(config)
                        ? buildNodes(setModal)
                        : buildNodes(setModal).reversed.toList(),
                  ),
                ),
                if (numLanes > 1)
                  Padding(
                    padding: EdgeInsets.only(left: config.padding),
                    child: EzIconButton(
                      config,
                      enabled: pos < (numLanes - 1),
                      icon: const Icon(Icons.keyboard_arrow_right),
                      onPressed: () => setModal(() => pos += 1),
                    ),
                  ),
              ],
            ),

            // Divider
            EzTitledDivider(
              config,
              title: Text('Align', textAlign: TextAlign.center, style: config.labelStyle),
              height: config.spacing * 3,
            ),

            // Align
            Container(
              color: config.colors.onSurface,
              height: heightOf(context) * sizeMod,
              width: widthOf(context) * sizeMod,
              child: Stack(
                children: <Widget>[
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      color: config.colors.surface,
                      image: (config.backgroundImagePath == noImageValue)
                          ? null
                          : config.backgroundImage,
                    ),
                    margin: EdgeInsets.all(config.marginVal * sizeMod),
                  ),

                  // Aligned circular icon (curr)
                  Align(
                    alignment: LAConfig.merge(h: hA, v: vA),
                    child: Container(
                      constraints: BoxConstraints.tightFor(
                        height: appIconSize(config),
                        width: appIconSize(config),
                      ),
                      decoration: BoxDecoration(
                        color: config.colors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          pos.toString(),
                          textAlign: TextAlign.center,
                          style: config.labelStyle?.copyWith(color: config.colors.onSecondary),
                        ),
                      ),
                    ),
                  ),

                  // Aligned circular icon (default)
                  Align(
                    alignment: LAConfig.merge(h: hDef, v: vDef),
                    child: ClipOval(
                      child: Image.asset(
                        appIconPath,
                        semanticLabel: 'Default list alignment',
                        width: appIconSize(config),
                        height: appIconSize(config),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            config.separator,

            // Controls
            EzWrap(
              children: <Widget>[
                // Horizontal
                SegmentedButton<ListAlignment>(
                  segments: alignmentSegments,
                  selected: <ListAlignment>{hA},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<ListAlignment>? choice) {
                    if (choice?.first == null) return;
                    setModal(() => hA = choice!.first);
                  },
                ),
                config.spacer,

                // Vertical
                SegmentedButton<ListAlignment>(
                  segments: alignmentSegments,
                  direction: Axis.vertical,
                  selected: <ListAlignment>{vA},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<ListAlignment>? choice) {
                    if (choice?.first == null) return;
                    setModal(() => vA = choice!.first);
                  },
                ),
              ],
            ),
            config.spacer,

            // GoTo settings
            EzTextIconButton(
              config,
              label: 'Page settings',
              style: TextButton.styleFrom(backgroundColor: config.colors.surfaceContainer),
              icon: EzIcon(config, Icons.launch),
              onPressed: () {
                Navigator.of(mCon).pop();
                context.goNamed(settingsPath, extra: (2, true));
              },
            ),
            config.separator,
          ],
        ),
      );
    },
  );

  await ezNoTouch(
    () => appInfo.updateLane(
      config,
      entry: _laneEntry(hA, vA),
      startPos: lane,
      currPos: pos,
    ),
  );
}

String defaultLaneEntry() => _laneEntry(null, null);

String _laneEntry(ListAlignment? hA, ListAlignment? vA) => <String>[
      hA?.value ?? esSystem,
      vA?.value ?? esSystem,
    ].join(configSplit);
