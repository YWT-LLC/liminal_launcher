/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../../screens/export.dart';
import '../../../utils/export.dart';
import '../../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class SwipeSelector extends StatefulWidget {
  final bool left;
  final String _key;

  const SwipeSelector({super.key, required this.left})
      : _key = left ? leftSwipeIDKey : rightSwipeIDKey;

  @override
  State<SwipeSelector> createState() => _SwipeSelectorState();
}

class _SwipeSelectorState extends State<SwipeSelector> {
  @override
  Widget build(BuildContext context) {
    // Define the build data //

    final String dir = widget.left ? 'Left' : 'Right';
    final String lowDir = dir.toLowerCase();

    final AppInfoProvider appInfo = Provider.of<AppInfoProvider>(context); // TODO: test me too

    String? appID = EzConfig.get(widget._key);
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
                style: EzConfig.bodyStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          hint: 'Choose app that opens on $lowDir swipe',
          style: EzConfig.bodyStyle,
        ),
        EzMargin(vertical: false),
        AppButton(
          app: app,
          labelType: listLabels,
          buttonType: listBT,
          onPressed: () => context.pushNamed(
            appListPath,
            extra: ListConfig(
              contents: <ListContent>{ListContent.banished},
              include: false,
              onSelected: (String id) async {
                final AppInfo? newApp = appInfo.appMap[id];
                if (newApp == null || newApp == app) {
                  if (context.mounted) Navigator.of(context).pop();
                  return;
                }

                await EzConfig.setString(widget._key, id);
                setState(() => app = newApp);

                if (context.mounted) Navigator.of(context).pop();
              },
              title: EzText(
                'Selecting $lowDir swipe',
                style: EzConfig.labelStyle,
              ),
            ),
          ),
          onLongPress: () async {
            appID = null;
            app = nullApp;

            await EzConfig.remove(widget._key);
            setState(() {});
          },
        ),
      ],
    );
  }
}
