/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../../screens/export.dart';
import '../../../utils/export.dart';
import '../../../widgets/export.dart';

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

    late final String dir = widget.left ? widget.config.ezL10n.gLeft : widget.config.ezL10n.gRight;
    final String lowDir = dir.toLowerCase();

    String? appID = EzCM.get(widget._key);
    AppInfo app =
        (appID == null || appID.isEmpty) ? nullApp : widget.appInfo.appMap[appID] ?? nullApp;

    // Return the build //

    return EzScrollView(
      widget.config,
      reverseHands: true,
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        EzLink(
          widget.config,
          text: l10n(widget.config).gsSwipe(dir),
          textColor: widget.config.colors.onSurface,
          backgroundColor: widget.config.colors.surfaceContainer,
          onTap: () => showDialog(
            context: context,
            builder: (_) => EzAlertDialog(
              widget.config,
              content: Text(
                l10n(widget.config).gsSwipeDesc(lowDir),
                style: widget.config.bodyStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          hint: l10n(widget.config).gsSwipeHint(lowDir),
          style: widget.config.bodyStyle,
        ),
        widget.config.rowMargin,
        AppButton(
          widget.config,
          name: app.label,
          image: app.icon,
          icon: null,
          iconSize: null,
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
              title: EzTextButton(
                widget.config,
                onPressed: doNothing,
                text: l10n(widget.config).gsSwipeLabel(lowDir),
                textStyle: widget.config.labelStyle,
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
