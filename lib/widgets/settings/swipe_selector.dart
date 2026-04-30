/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../../screens/export.dart';
import '../../../utils/export.dart';
import '../../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class SwipeSelector extends StatefulWidget {
  final bool left;

  final String _darkKey;
  final String _lightKey;

  const SwipeSelector({super.key, required this.left})
      : _darkKey = left ? darkLeftSwipeIDKey : darkRightSwipeIDKey,
        _lightKey = left ? lightLeftSwipeIDKey : lightRightSwipeIDKey;

  @override
  State<SwipeSelector> createState() => _SwipeSelectorState();
}

class _SwipeSelectorState extends State<SwipeSelector> {
  @override
  Widget build(BuildContext context) {
    // Define the build data //

    final String dir = widget.left ? 'Left' : 'Right';
    final String lowDir = dir.toLowerCase();

    String? appID = EzConfig.get(EzConfig.isDark ? widget._darkKey : widget._lightKey);
    AppInfo app = (appID == null || appID.isEmpty) ? nullApp : appInfo.appMap[appID] ?? nullApp;

    // Return the build //

    return EzRow(
      children: <Widget>[
        EzLink(
          '$dir app',
          textColor: EzConfig.colors.onSurface,
          onTap: () => showDialog(
            context: context,
            builder: (_) => EzAlertDialog(
              content: Text(
                'Choose a quick access app that will open when you swipe $lowDir on the home screen.',
                style: EzConfig.styles.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          hint: 'Choose app that opens on $lowDir swipe',
          style: EzConfig.styles.bodyLarge,
          padding: EzInsets.wrap(EzConfig.marginVal),
        ),
        EzMargin(vertical: false),
        TileButton(
          app: app,
          labelType: listLabels,
          showIcon: listIcons,
          onPressed: () => context.pushNamed(
            appListPath,
            extra: ListConfig(
              ids: appInfo.banishedSet,
              include: false,
              onSelected: (String id) async {
                final AppInfo? newApp = appInfo.appMap[id];
                if (newApp == null || newApp == app) {
                  if (context.mounted) Navigator.of(context).pop();
                  return;
                }

                if (EzConfig.updateBoth || EzConfig.isDark) {
                  await EzConfig.setString(widget._darkKey, id);
                }
                if (EzConfig.updateBoth || !EzConfig.isDark) {
                  await EzConfig.setString(widget._lightKey, id);
                }

                setState(() => app = newApp);
                if (context.mounted) Navigator.of(context).pop();
              },
              title: EzText(
                'Selecting $lowDir swipe',
                style: EzConfig.styles.labelLarge,
              ),
            ),
          ),
          onLongPress: () async {
            appID = null;
            app = nullApp;

            if (EzConfig.updateBoth || EzConfig.isDark) {
              await EzConfig.remove(widget._darkKey);
            }
            if (EzConfig.updateBoth || !EzConfig.isDark) {
              await EzConfig.remove(widget._lightKey);
            }

            setState(() {});
          },
        ),
      ],
    );
  }
}
