import '../../screens/export.dart';
import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class LeftSwipeSelector extends StatefulWidget {
  final AppInfoProvider listener;
  final TextTheme textTheme;

  const LeftSwipeSelector({
    super.key,
    required this.listener,
    required this.textTheme,
  });

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

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return EzRow(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        EzText('Left package', style: widget.textTheme.bodyLarge),
        EzMargin(vertical: false),
        TileButton(
          app: app,
          type: labelType,
          showIcon: showIcon,
          onPressed: () => context.goNamed(
            appListPath,
            extra: listData(
              listCheck: (String id) => true,
              onSelected: (String id) async {
                final AppInfo? newApp = widget.listener.appMap[id];
                if (newApp == null || newApp == app) return;

                await EzConfig.setString(leftSwipeIDKey, id);
                setState(() => app = newApp);
              },
              refresh: () => setState(() {}),
              icon: Text(
                'Selecting left swipe',
                style: textTheme.labelLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RightSwipeSelector extends StatefulWidget {
  final AppInfoProvider listener;
  final TextTheme textTheme;

  const RightSwipeSelector({
    super.key,
    required this.listener,
    required this.textTheme,
  });

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

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return EzRow(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        EzText('Right package', style: widget.textTheme.bodyLarge),
        EzMargin(vertical: false),
        TileButton(
          app: app,
          type: labelType,
          showIcon: showIcon,
          onPressed: () => context.goNamed(
            appListPath,
            extra: listData(
              listCheck: (String id) => true,
              onSelected: (String id) async {
                final AppInfo? newApp = widget.listener.appMap[id];
                if (newApp == null || newApp == app) return;

                await EzConfig.setString(rightSwipeIDKey, id);
                setState(() => app = newApp);
              },
              refresh: () => setState(() {}),
              icon: Text(
                'Selecting right swipe',
                style: textTheme.labelLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
