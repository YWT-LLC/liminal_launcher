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
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SwipeSelector extends StatefulWidget {
  final bool left;
  final AppInfoProvider listener;

  const SwipeSelector({super.key, required this.left, required this.listener});

  @override
  State<SwipeSelector> createState() => _SwipeSelectorState();
}

class _SwipeSelectorState extends State<SwipeSelector> {
  // Define the build data //

  final bool showIcon = EzConfig.get(listIconKey);
  final LabelType labelType =
      LabelTypeConfig.fromValue(EzConfig.get(listLabelTypeKey));

  late String key = widget.left ? leftSwipeIDKey : rightSwipeIDKey;
  late String dir = widget.left ? 'Left' : 'Right';
  late String lowDir = dir.toLowerCase();

  late String? appID = EzConfig.get(key);
  late AppInfo app = (appID == null || appID!.isEmpty)
      ? nullApp
      : widget.listener.appMap[appID!] ?? nullApp;

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return EzRow(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        EzLink(
          '$dir app',
          textColor: colorScheme.onSurface,
          onTap: () => showPlatformDialog(
            context: context,
            builder: (_) => EzAlertDialog(
              content: Text(
                'Choose a quick access app that will open when you swipe $lowDir on the home screen.',
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          hint: 'Choose app that opens on $lowDir swipe',
          style: textTheme.bodyLarge,
          padding: EzInsets.wrap(EzConfig.get(marginKey)),
        ),
        ezRowMargin,
        TileButton(
          app: app,
          labelType: labelType,
          showIcon: showIcon,
          onPressed: () => context.pushNamed(
            appListPath,
            extra: listData(
              listCheck: (String id) => true,
              onSelected: (String id) async {
                final AppInfo? newApp = widget.listener.appMap[id];
                if (newApp == null || newApp == app) {
                  if (context.mounted) Navigator.of(context).pop();
                  return;
                }

                await EzConfig.setString(key, id);
                setState(() => app = newApp);
                if (context.mounted) Navigator.of(context).pop();
              },
              refresh: () => setState(() {}),
              icon: EzText(
                'Selecting $lowDir swipe',
                style: textTheme.labelLarge,
              ),
            ),
          ),
          onLongPress: () async {
            await EzConfig.remove(key);
            setState(() {
              appID = null;
              app = nullApp;
            });
          },
        ),
      ],
    );
  }
}
