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

  const SwipeSelector({super.key, required this.left});

  @override
  State<SwipeSelector> createState() => _SwipeSelectorState();
}

class _SwipeSelectorState extends State<SwipeSelector> {
  @override
  Widget build(BuildContext context) {
    // Define the build data //

    final String key = widget.left
        ? (EzConfig.isDark ? darkLeftSwipeIDKey : lightLeftSwipeIDKey)
        : (EzConfig.isDark ? darkRightSwipeIDKey : lightRightSwipeIDKey);
    final String dir = widget.left ? 'Left' : 'Right';
    final String lowDir = dir.toLowerCase();

    String? appID = EzConfig.get(key);
    AppInfo app = (appID == null || appID.isEmpty)
        ? nullApp
        : appInfo.appMap[appID] ?? nullApp;

    final bool showIcon =
        EzConfig.get(EzConfig.isDark ? darkListIconKey : lightListIconKey);
    final LabelType labelType = LabelTypeConfig.lookup(EzConfig.get(
        EzConfig.isDark ? darkListLabelTypeKey : lightListLabelTypeKey));

    // Return the build //

    return EzRow(
      mainAxisSize: MainAxisSize.min,
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
          labelType: labelType,
          showIcon: showIcon,
          onPressed: () => context.pushNamed(
            appListPath,
            extra: listData(
              listCheck: (String id) => true,
              onSelected: (String id) async {
                final AppInfo? newApp = appInfo.appMap[id];
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
                style: EzConfig.styles.labelLarge,
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
