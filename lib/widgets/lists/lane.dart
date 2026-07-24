/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:open_ui/open_ui.dart';

// TODO: is custom alignment working?

//* Core Widget *//

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

//* Edit Widget *//

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
                EzScrollView(
                  config,
                  startCentered: true,
                  scrollDirection: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: standardFlow(config)
                      ? buildNodes(setModal)
                      : buildNodes(setModal).reversed.toList(),
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
              Text('Align', textAlign: TextAlign.center, style: config.labelStyle),
              height: config.spacing * 3,
              margin: config.marginVal,
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
            config.separator,
          ],
        ),
      );
    },
  );

  await ezNoTouch(
    () async => await appInfo.updateLane(
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
