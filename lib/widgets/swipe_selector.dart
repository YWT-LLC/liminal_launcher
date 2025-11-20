/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class LeftSwipeSelector extends StatefulWidget {
  final AppInfoProvider listener;

  const LeftSwipeSelector({super.key, required this.listener});

  @override
  State<LeftSwipeSelector> createState() => _LeftSwipeSelectorState();
}

class _LeftSwipeSelectorState extends State<LeftSwipeSelector> {
  // Define the build data //

  final bool showIcon = EzConfig.get(listIconKey);
  final LabelType labelType =
      LabelTypeConfig.fromValue(EzConfig.get(listLabelTypeKey));

  late String? appID = EzConfig.get(leftSwipeIDKey);
  late AppInfo app = (appID == null || appID!.isEmpty)
      ? nullApp
      : widget.listener.appMap[appID!] ?? nullApp;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Define custom functions //

    void activate() => context.pushNamed(
          appListPath,
          extra: listData(
            listCheck: (String id) => true,
            onSelected: (String id) async {
              final AppInfo? newApp = widget.listener.appMap[id];
              if (newApp == null || newApp == app) return;

              await EzConfig.setString(leftSwipeIDKey, id);
              setState(() => app = newApp);
              if (context.mounted) Navigator.of(context).pop();
            },
            refresh: () => setState(() {}),
            icon: EzText(
              'Selecting left swipe',
              style: textTheme.labelLarge,
            ),
          ),
        );

    // Return the build //

    return EzRow(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        EzLink(
          'Left app',
          textColor: colorScheme.onSurface,
          onTap: activate,
          hint: 'Choose app that opens on left swipe',
          style: textTheme.bodyLarge,
          padding: EzInsets.wrap(EzConfig.get(marginKey)),
        ),
        ezRowMargin,
        TileButton(
          app: app,
          labelType: labelType,
          showIcon: showIcon,
          onPressed: activate,
        ),
      ],
    );
  }
}

class RightSwipeSelector extends StatefulWidget {
  final AppInfoProvider listener;

  const RightSwipeSelector({super.key, required this.listener});

  @override
  State<RightSwipeSelector> createState() => _RightSwipeSelectorState();
}

class _RightSwipeSelectorState extends State<RightSwipeSelector> {
  // Define the build data //

  final bool showIcon = EzConfig.get(listIconKey);
  final LabelType labelType =
      LabelTypeConfig.fromValue(EzConfig.get(listLabelTypeKey));

  late String? appID = EzConfig.get(rightSwipeIDKey);
  late AppInfo app = (appID == null || appID!.isEmpty)
      ? nullApp
      : widget.listener.appMap[appID!] ?? nullApp;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Define custom functions //

    void activate() => context.pushNamed(
          appListPath,
          extra: listData(
            listCheck: (String id) => true,
            onSelected: (String id) async {
              final AppInfo? newApp = widget.listener.appMap[id];
              if (newApp == null || newApp == app) return;

              await EzConfig.setString(rightSwipeIDKey, id);
              setState(() => app = newApp);
              if (context.mounted) Navigator.of(context).pop();
            },
            refresh: () => setState(() {}),
            icon: EzText(
              'Selecting right swipe',
              style: textTheme.labelLarge,
            ),
          ),
        );

    // Return the build //

    return EzRow(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        EzLink(
          'Right app',
          textColor: colorScheme.onSurface,
          onTap: activate,
          hint: 'Choose app that opens on right swipe',
          style: textTheme.bodyLarge,
          padding: EzInsets.wrap(EzConfig.get(marginKey)),
        ),
        ezRowMargin,
        TileButton(
          app: app,
          labelType: labelType,
          showIcon: showIcon,
          onPressed: activate,
        ),
      ],
    );
  }
}
