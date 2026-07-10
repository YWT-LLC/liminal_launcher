/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

List<Widget> appMC(
  EzCP config,
  AppInfoProvider appInfo, {
  required BuildContext context,
  Widget? edit,
  required int numLanes,
  required int? lane,
  required int? index,
  required AppInfo app,
  required bool homeTile,
}) =>
    (lane != null && index != null)
        ? _tileMC(
            config,
            appInfo,
            edit: edit,
            configure: _configureApp(config, appInfo,
                context: context, lane: lane, index: index, app: app, homeTile: homeTile),
            numLanes: homeTile ? numLanes : -1,
            lane: lane,
            index: index,
          )
        : _miniTileMC(
            config,
            appInfo,
            edit: edit,
            configure: _configureApp(config, appInfo,
                context: context, lane: lane, index: index, app: app, homeTile: homeTile),
          );

Widget _configureApp(
  EzCP config,
  AppInfoProvider appInfo, {
  required BuildContext context,
  required int? lane,
  required int? index,
  required AppInfo app,
  required bool homeTile,
}) =>
    SubmenuButton(
      menuChildren: <Widget>[
        // Info
        EzMenuButton(
          config,
          label: 'Info',
          icon: EzIcon(config, Icons.info),
          onPressed: () async {
            if (!homeTile && context.mounted) Navigator.of(context).pop();
            await openSettings(app);
          },
        ),

        // Dupe
        if (homeTile)
          EzMenuButton(
            config,
            label: 'Duplicate',
            icon: EzIcon(config, Icons.copy),
            onPressed: () async {
              await appInfo.dupeItem(config, lane: lane!, index: index!);
            },
          ),

        // Show/hide
        appInfo.hidden(config).contains(app.id)
            ? EzMenuButton(
                config,
                label: 'Show',
                icon: EzIcon(config, Icons.visibility),
                onPressed: () async => await appInfo.showApp(config, app.id),
              )
            : EzMenuButton(
                config,
                label: 'Hide',
                icon: EzIcon(config, Icons.visibility_off),
                onPressed: () async => await appInfo.hideApp(config, context, app.id),
              ),

        // Banish
        EzMenuButton(
          config,
          label: 'Banish',
          icon: EzIcon(config, LineIcons.ghost),
          onPressed: () async => await appInfo.banishApp(config, context, app.id),
        ),

        // Uninstall
        if (app.removable)
          EzMenuButton(
            config,
            label: 'Uninstall',
            icon: EzIcon(config, Icons.delete),
            onPressed: () async => await openDelete(app),
          ),
      ],
      child: EzIcon(config, Icons.build),
    );

List<Widget> folderMC(
  EzCP config,
  AppInfoProvider appInfo,
  Widget edit, {
  required int numLanes,
  required int lane,
  required int index,
}) =>
    _tileMC(config, appInfo, edit: edit, numLanes: numLanes, lane: lane, index: index);

Widget moveDownLane(
  EzCP config,
  AppInfoProvider appInfo, {
  required int numLanes,
  required int lane,
  required int index,
}) =>
    EzMenuButton(
      config,
      enabled: lane != 0,
      icon: EzIcon(
        config,
        config.isLTR && horizontalAlign(config) != ListAlignment.end
            ? Icons.keyboard_arrow_left
            : Icons.keyboard_arrow_right,
      ),
      onPressed: () => appInfo.moveItemDownLane(config, lane: lane, index: index),
    );

Widget moveUpLane(
  EzCP config,
  AppInfoProvider appInfo, {
  required int numLanes,
  required int lane,
  required int index,
}) =>
    EzMenuButton(
      config,
      enabled: lane < (numLanes - 1),
      icon: EzIcon(
        config,
        config.isLTR && horizontalAlign(config) != ListAlignment.end
            ? Icons.keyboard_arrow_right
            : Icons.keyboard_arrow_left,
      ),
      onPressed: () => appInfo.moveItemUpLane(config, lane: lane, index: index),
    );

Widget removeItem(
  EzCP config,
  AppInfoProvider appInfo, {
  required int lane,
  required int index,
}) =>
    EzMenuButton(
      config,
      label: 'Remove',
      icon: EzIcon(config, Icons.remove),
      onPressed: () => appInfo.removeItem(config, lane: lane, index: index),
    );

List<Widget> _tileMC(
  EzCP config,
  AppInfoProvider appInfo, {
  Widget? edit,
  Widget? configure,
  List<Widget>? local,
  required int numLanes,
  required int lane,
  required int index,
}) =>
    local == null
        ? (numLanes > 1)
            ? <Widget>[
                moveDownLane(config, appInfo, numLanes: numLanes, lane: lane, index: index),
                if (configure != null) configure,
                if (edit != null) edit,
                removeItem(config, appInfo, lane: lane, index: index),
                moveUpLane(config, appInfo, numLanes: numLanes, lane: lane, index: index),
              ]
            : <Widget>[
                if (configure != null) configure,
                if (edit != null) edit,
                if (numLanes > 0) removeItem(config, appInfo, lane: lane, index: index),
              ] // > 0 is specifically for appMC
        : <Widget>[
            ...local,
            if (configure != null) configure,
            if (edit != null) edit,
            removeItem(config, appInfo, lane: lane, index: index),
          ]; // local is only for Widget(ception: WidWidGetGet)

/// When there's no lane/index info
List<Widget> _miniTileMC(
  EzCP config,
  AppInfoProvider appInfo, {
  Widget? edit,
  Widget? configure,
  List<Widget>? local,
}) =>
    <Widget>[
      if (local != null) ...local,
      if (configure != null) configure,
      if (edit != null) edit,
    ];

List<Widget> widgetMC(
  EzCP config,
  AppInfoProvider appInfo,
  Widget edit, {
  List<Widget>? local,
  required int numLanes,
  required int lane,
  required int index,
}) =>
    _tileMC(config, appInfo,
        edit: edit, local: local, numLanes: numLanes, lane: lane, index: index);
