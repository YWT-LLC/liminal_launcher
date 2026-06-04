/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppListSettings extends StatelessWidget {
  const AppListSettings({super.key});

  @override
  Widget build(BuildContext context) => EzElevatedIconButton(
        label: 'App list',
        icon: const Icon(Icons.list),
        onPressed: () => ezModal(
          context: context,
          builder: (_) => ezModalScroll(
            <Widget>[
              // Auto add to home
              const EzSwitchPair(
                text: 'Auto-add new apps to home',
                valueKey: autoAddToHomeKey,
              ),
              EzConfig.spacer,

              // Auto search
              const EzSwitchPair(
                text: 'Auto-search the apps list',
                valueKey: autoSearchKey,
              ),
              EzConfig.separator,

              // Swipe selectors
              EzDivider(
                title: Text(
                  'Quick launch',
                  textAlign: TextAlign.center,
                  style: EzConfig.titleStyle,
                ),
                height: 0,
              ),
              EzNewLine(style: EzConfig.labelStyle),
              Text(
                'Swipe left/right on the home screen (except when editing) to open the selected app.\nLong press to clear your selection.',
                textAlign: TextAlign.center,
                style: EzConfig.labelStyle,
              ),
              EzConfig.spacer,
              const SwipeSelector(left: true),
              EzConfig.spacer,
              const SwipeSelector(left: false),
              EzConfig.separator,
            ],
          ),
        ),
      );
}
