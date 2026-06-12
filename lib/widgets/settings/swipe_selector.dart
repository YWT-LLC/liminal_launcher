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
  final EzCP config;
  final AppInfoProvider appInfo;
  final bool left;
  final String _key;

  const SwipeSelector(this.config, this.appInfo, {super.key, required this.left})
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

    String? appID = EzCM.get(widget._key);
    AppInfo app =
        (appID == null || appID.isEmpty) ? nullApp : widget.appInfo.appMap[appID] ?? nullApp;

    // Return the build //

    return EzRow(
      widget.config,
      children: <Widget>[
        EzLink(
          widget.config,
          text: '$dir app',
          textColor: widget.config.colors.onSurface,
          onTap: () => showDialog(
            context: context,
            builder: (_) => EzAlertDialog(
              widget.config,
              content: Text(
                'Choose a quick access app that will open when you swipe $lowDir on the home screen.',
                style: widget.config.bodyStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          hint: 'Choose app that opens on $lowDir swipe',
          style: widget.config.bodyStyle,
        ),
        widget.config.rowMargin,
        AppButton(
          widget.config,
          app: app,
          labelType: listLabels(widget.config),
          buttonType: listBT(widget.config),
          onPressed: () => context.pushNamed(
            appListPath,
            extra: ListConfig(
              listContent: <ListContent>{ListContent.banished},
              include: false,
              onSelected: (AppInfo newApp) async {
                if (newApp == app) {
                  if (context.mounted) Navigator.of(context).pop();
                  return;
                }

                await EzCM.setString(widget._key, newApp.id);
                setState(() => app = newApp);

                if (context.mounted) Navigator.of(context).pop();
              },
              title: EzText(
                widget.config,
                text: 'Selecting $lowDir swipe',
                style: widget.config.labelStyle,
              ),
            ),
          ),
          onLongPress: () async {
            appID = null;
            app = nullApp;

            await EzCM.remove(widget._key);
            setState(() {});
          },
        ),
      ],
    );
  }
}
